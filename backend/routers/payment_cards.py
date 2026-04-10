from datetime import datetime, timezone
import secrets

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_current_user
from models import PaymentCard, User
from schemas.payment import PaymentCardCreateRequest, PaymentCardResponse

router = APIRouter(tags=["payment_cards"])


def _digits_only(value: str) -> str:
    return "".join(char for char in value if char.isdigit())


def _detect_card_brand(number: str) -> str:
    if number.startswith("4"):
        return "Visa"
    if number[:2] in {"34", "37"}:
        return "Amex"
    if 51 <= int(number[:2]) <= 55 or 2221 <= int(number[:4]) <= 2720:
        return "Mastercard"
    if number.startswith("6011") or number.startswith("65"):
        return "Discover"
    return "Card"


def _expiry_is_past(month: int, year: int) -> bool:
    now = datetime.now(timezone.utc)
    return (year < now.year) or (year == now.year and month < now.month)


@router.get("/payment-cards", response_model=list[PaymentCardResponse])
def list_payment_cards(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[PaymentCard]:
    return (
        db.query(PaymentCard)
        .filter(PaymentCard.user_id == current_user.id)
        .order_by(PaymentCard.is_default.desc(), PaymentCard.created_at.desc())
        .all()
    )


@router.post("/payment-cards", response_model=PaymentCardResponse, status_code=status.HTTP_201_CREATED)
def create_payment_card(
    payload: PaymentCardCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PaymentCard:
    card_number = _digits_only(payload.card_number)
    if len(card_number) < 12 or len(card_number) > 19:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid card number")

    if not payload.cvv.isdigit() or len(payload.cvv) not in {3, 4}:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid CVV")

    if _expiry_is_past(payload.expiry_month, payload.expiry_year):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Card has expired")

    existing_count = db.query(PaymentCard).filter(PaymentCard.user_id == current_user.id).count()
    is_default = payload.set_as_default or existing_count == 0

    if is_default:
        (
            db.query(PaymentCard)
            .filter(PaymentCard.user_id == current_user.id)
            .update({PaymentCard.is_default: False}, synchronize_session=False)
        )

    card = PaymentCard(
        user_id=current_user.id,
        token=f"pc_{secrets.token_urlsafe(24)}",
        brand=_detect_card_brand(card_number),
        last4=card_number[-4:],
        expiry_month=payload.expiry_month,
        expiry_year=payload.expiry_year,
        cardholder_name=(payload.cardholder_name or "").strip() or None,
        is_default=is_default,
    )

    db.add(card)
    db.commit()
    db.refresh(card)
    return card


@router.patch("/payment-cards/{card_id}/default", response_model=PaymentCardResponse)
def set_default_payment_card(
    card_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PaymentCard:
    card = (
        db.query(PaymentCard)
        .filter(PaymentCard.id == card_id, PaymentCard.user_id == current_user.id)
        .first()
    )
    if card is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Payment card not found")

    (
        db.query(PaymentCard)
        .filter(PaymentCard.user_id == current_user.id)
        .update({PaymentCard.is_default: False}, synchronize_session=False)
    )
    card.is_default = True
    db.commit()
    db.refresh(card)
    return card


@router.delete("/payment-cards/{card_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_payment_card(
    card_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Response:
    card = (
        db.query(PaymentCard)
        .filter(PaymentCard.id == card_id, PaymentCard.user_id == current_user.id)
        .first()
    )
    if card is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Payment card not found")

    deleted_default = card.is_default
    db.delete(card)
    db.commit()

    if deleted_default:
        replacement = (
            db.query(PaymentCard)
            .filter(PaymentCard.user_id == current_user.id)
            .order_by(PaymentCard.created_at.desc())
            .first()
        )
        if replacement is not None:
            replacement.is_default = True
            db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)