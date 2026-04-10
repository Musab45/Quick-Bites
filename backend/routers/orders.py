from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, selectinload

from database import get_db
from dependencies import get_current_user
from models import (
    MenuItem,
    Order,
    OrderItem,
    OrderStatus,
    PaymentCard,
    Restaurant,
    User,
    Wallet,
)
from schemas.order import OrderCreateRequest, OrderResponse

router = APIRouter(tags=["orders"])

ALLOWED_PAYMENT_METHODS = {"card", "cash", "wallet"}


@router.post("/orders", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    payload: OrderCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Order:
    payment_method = payload.payment_method.strip().lower()
    if payment_method not in ALLOWED_PAYMENT_METHODS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="payment_method must be one of: card, wallet, cash",
        )

    if payload.saved_card_id is not None and payment_method != "card":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="saved_card_id is only supported for card payments",
        )

    if payload.saved_card_id is not None:
        payment_card = (
            db.query(PaymentCard)
            .filter(
                PaymentCard.id == payload.saved_card_id,
                PaymentCard.user_id == current_user.id,
            )
            .first()
        )
        if payment_card is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Saved card not found",
            )

    restaurant = db.query(Restaurant).filter(Restaurant.id == payload.restaurant_id).first()
    if restaurant is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")

    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Order items cannot be empty")

    item_ids = [item.menu_item_id for item in payload.items]
    db_menu_items = db.query(MenuItem).filter(MenuItem.id.in_(item_ids)).all()
    menu_map = {item.id: item for item in db_menu_items}

    total_amount = 0.0
    order_items: list[OrderItem] = []

    for request_item in payload.items:
        menu_item = menu_map.get(request_item.menu_item_id)
        if menu_item is None or menu_item.restaurant_id != payload.restaurant_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid menu item: {request_item.menu_item_id}",
            )

        line_total = menu_item.price * request_item.quantity
        total_amount += line_total
        order_items.append(
            OrderItem(
                menu_item_id=menu_item.id,
                name=menu_item.name,
                quantity=request_item.quantity,
                unit_price=menu_item.price,
                line_total=line_total,
            )
        )

    order_total = round(total_amount, 2)

    if payment_method == "wallet":
        wallet = db.query(Wallet).filter(Wallet.user_id == current_user.id).first()
        if wallet is None:
            wallet = Wallet(user_id=current_user.id, balance=0.0)
            db.add(wallet)
            db.flush()

        if wallet.balance + 1e-9 < order_total:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Insufficient wallet balance. "
                    f"Available {wallet.balance:.2f}, required {order_total:.2f}"
                ),
            )
        wallet.balance = round(wallet.balance - order_total, 2)

    order = Order(
        user_id=current_user.id,
        restaurant_id=payload.restaurant_id,
        address=payload.address,
        payment_method=payment_method,
        status=OrderStatus.pending.value,
        total_amount=order_total,
        estimated_delivery_minutes=30,
        items=order_items,
    )

    db.add(order)
    db.commit()
    db.refresh(order)

    order_with_items = (
        db.query(Order)
        .options(selectinload(Order.items))
        .filter(Order.id == order.id)
        .first()
    )
    return order_with_items if order_with_items is not None else order


@router.get("/orders", response_model=list[OrderResponse])
def list_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[Order]:
    return (
        db.query(Order)
        .options(selectinload(Order.items))
        .filter(Order.user_id == current_user.id)
        .order_by(Order.created_at.desc())
        .all()
    )


@router.get("/orders/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Order:
    order = (
        db.query(Order)
        .options(selectinload(Order.items))
        .filter(Order.id == order_id, Order.user_id == current_user.id)
        .first()
    )
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return order
