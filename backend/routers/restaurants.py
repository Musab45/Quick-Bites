from math import ceil

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from database import get_db
from models import MenuItem, Restaurant
from schemas.restaurant import (
    RestaurantResponse,
    RestaurantSearchPageResponse,
    SearchSuggestionsResponse,
)

router = APIRouter(tags=["restaurants"])


@router.get("/restaurants", response_model=list[RestaurantResponse])
def list_restaurants(db: Session = Depends(get_db)) -> list[Restaurant]:
    return db.query(Restaurant).order_by(Restaurant.id.asc()).all()


@router.get("/restaurants/search", response_model=RestaurantSearchPageResponse)
def search_restaurants(
    q: str = Query(default="", max_length=80),
    cuisine: str | None = Query(default=None, max_length=80),
    open_now: bool | None = None,
    max_delivery_fee: float | None = Query(default=None, ge=0, le=50),
    max_delivery_time: int | None = Query(default=None, ge=5, le=180),
    min_rating: float | None = Query(default=None, ge=0, le=5),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    sort: str = Query(default="rating_desc", pattern="^(rating_desc|delivery_time_asc|delivery_fee_asc)$"),
    db: Session = Depends(get_db),
) -> RestaurantSearchPageResponse:
    query = db.query(Restaurant)

    normalized = q.strip()
    if normalized:
        pattern = f"%{normalized}%"
        menu_match = (
            db.query(MenuItem.id)
            .filter(
                MenuItem.restaurant_id == Restaurant.id,
                MenuItem.name.ilike(pattern),
            )
            .exists()
        )
        query = query.filter(
            or_(
                Restaurant.name.ilike(pattern),
                Restaurant.cuisine_type.ilike(pattern),
                menu_match,
            )
        )

    if cuisine and cuisine.strip():
        query = query.filter(Restaurant.cuisine_type.ilike(f"%{cuisine.strip()}%"))

    if open_now is not None:
        query = query.filter(Restaurant.is_open == open_now)

    if max_delivery_fee is not None:
        query = query.filter(Restaurant.delivery_fee <= max_delivery_fee)

    if max_delivery_time is not None:
        query = query.filter(Restaurant.delivery_time_minutes <= max_delivery_time)

    if min_rating is not None:
        query = query.filter(Restaurant.rating >= min_rating)

    if sort == "delivery_time_asc":
        query = query.order_by(Restaurant.delivery_time_minutes.asc(), Restaurant.id.asc())
    elif sort == "delivery_fee_asc":
        query = query.order_by(Restaurant.delivery_fee.asc(), Restaurant.id.asc())
    else:
        query = query.order_by(Restaurant.rating.desc(), Restaurant.id.asc())

    total_items = query.count()
    offset = (page - 1) * page_size
    items = query.offset(offset).limit(page_size).all()
    total_pages = ceil(total_items / page_size) if total_items > 0 else 0

    return RestaurantSearchPageResponse(
        items=[RestaurantResponse.model_validate(item) for item in items],
        page=page,
        page_size=page_size,
        total_items=total_items,
        total_pages=total_pages,
    )


@router.get("/restaurants/suggestions", response_model=SearchSuggestionsResponse)
def restaurant_suggestions(
    q: str = Query(min_length=1, max_length=80),
    limit: int = Query(default=8, ge=1, le=20),
    db: Session = Depends(get_db),
) -> SearchSuggestionsResponse:
    normalized = q.strip()
    if not normalized:
        return SearchSuggestionsResponse(suggestions=[])

    pattern = f"%{normalized}%"
    suggestions: list[str] = []
    seen: set[str] = set()

    restaurant_names = (
        db.query(Restaurant.name)
        .filter(Restaurant.name.ilike(pattern))
        .order_by(Restaurant.rating.desc(), Restaurant.name.asc())
        .limit(limit)
        .all()
    )
    cuisine_names = (
        db.query(Restaurant.cuisine_type)
        .filter(Restaurant.cuisine_type.ilike(pattern))
        .distinct()
        .limit(limit)
        .all()
    )
    menu_names = (
        db.query(MenuItem.name)
        .filter(MenuItem.name.ilike(pattern))
        .distinct()
        .limit(limit)
        .all()
    )

    for value in [*restaurant_names, *cuisine_names, *menu_names]:
        candidate = (value[0] or "").strip()
        if not candidate:
            continue
        key = candidate.lower()
        if key in seen:
            continue
        seen.add(key)
        suggestions.append(candidate)
        if len(suggestions) >= limit:
            break

    return SearchSuggestionsResponse(suggestions=suggestions)


@router.get("/restaurants/{restaurant_id}", response_model=RestaurantResponse)
def get_restaurant(restaurant_id: int, db: Session = Depends(get_db)) -> Restaurant:
    restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()
    if restaurant is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return restaurant
