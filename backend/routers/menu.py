from collections import defaultdict

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import MenuItem
from schemas.restaurant import MenuItemResponse

router = APIRouter(tags=["menu"])


@router.get("/menu/{restaurant_id}")
def get_menu_by_restaurant(restaurant_id: int, db: Session = Depends(get_db)) -> dict[str, list[MenuItemResponse]]:
    items = (
        db.query(MenuItem)
        .filter(MenuItem.restaurant_id == restaurant_id)
        .order_by(MenuItem.category.asc(), MenuItem.id.asc())
        .all()
    )
    grouped: dict[str, list[MenuItemResponse]] = defaultdict(list)
    for item in items:
        grouped[item.category].append(MenuItemResponse.model_validate(item))
    return grouped
