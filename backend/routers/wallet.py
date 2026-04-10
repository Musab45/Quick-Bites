from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from database import get_db
from dependencies import get_current_user
from models import User, Wallet
from schemas.payment import WalletResponse, WalletTopUpRequest

router = APIRouter(tags=["wallet"])


def _get_or_create_wallet(db: Session, user_id: int) -> Wallet:
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if wallet is not None:
        return wallet

    wallet = Wallet(user_id=user_id, balance=0.0)
    db.add(wallet)
    db.flush()
    return wallet


@router.get("/wallet", response_model=WalletResponse)
def get_wallet(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Wallet:
    wallet = _get_or_create_wallet(db, current_user.id)
    db.commit()
    db.refresh(wallet)
    return wallet


@router.post(
    "/wallet/top-up",
    response_model=WalletResponse,
    status_code=status.HTTP_200_OK,
)
def top_up_wallet(
    payload: WalletTopUpRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Wallet:
    wallet = _get_or_create_wallet(db, current_user.id)
    wallet.balance = round(wallet.balance + payload.amount, 2)
    db.commit()
    db.refresh(wallet)
    return wallet