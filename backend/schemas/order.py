from datetime import datetime

from pydantic import BaseModel, Field


class OrderCreateItem(BaseModel):
    menu_item_id: int
    quantity: int = Field(gt=0, le=50)


class OrderCreateRequest(BaseModel):
    restaurant_id: int
    address: str = Field(min_length=5, max_length=255)
    payment_method: str = Field(min_length=2, max_length=50)
    items: list[OrderCreateItem]


class OrderItemResponse(BaseModel):
    id: int
    menu_item_id: int
    name: str
    quantity: int
    unit_price: float
    line_total: float

    model_config = {"from_attributes": True}


class OrderResponse(BaseModel):
    id: int
    user_id: int
    restaurant_id: int
    address: str
    payment_method: str
    status: str
    total_amount: float
    estimated_delivery_minutes: int
    created_at: datetime
    items: list[OrderItemResponse]

    model_config = {"from_attributes": True}
