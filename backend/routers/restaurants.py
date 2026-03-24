from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import Restaurant
from schemas.restaurant import RestaurantResponse

router = APIRouter(tags=["restaurants"])


@router.get("/restaurants", response_model=list[RestaurantResponse])
def list_restaurants(db: Session = Depends(get_db)) -> list[Restaurant]:
    return db.query(Restaurant).order_by(Restaurant.id.asc()).all()


@router.get("/restaurants/{restaurant_id}", response_model=RestaurantResponse)
def get_restaurant(restaurant_id: int, db: Session = Depends(get_db)) -> Restaurant:
    restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()
    if restaurant is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return restaurant
