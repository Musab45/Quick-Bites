from pydantic import BaseModel


class RestaurantResponse(BaseModel):
    id: int
    name: str
    image_url: str
    rating: float
    delivery_time_minutes: int
    delivery_fee: float
    cuisine_type: str
    is_open: bool

    model_config = {"from_attributes": True}


class MenuItemResponse(BaseModel):
    id: int
    restaurant_id: int
    name: str
    description: str
    category: str
    price: float
    image_url: str
    is_available: bool

    model_config = {"from_attributes": True}
