from database import SessionLocal, init_db
from models import MenuItem, Restaurant, User
from security import hash_password


def run_seed() -> None:
    init_db()
    db = SessionLocal()
    try:
        if db.query(User).filter(User.email == "demo@quickbite.dev").first() is None:
            db.add(
                User(
                    email="demo@quickbite.dev",
                    full_name="Demo User",
                    password_hash=hash_password("DemoPass123"),
                )
            )

        if db.query(Restaurant).count() == 0:
            restaurants = [
                Restaurant(
                    name="Burger Hub",
                    image_url="https://picsum.photos/800/600?burger",
                    rating=4.6,
                    delivery_time_minutes=25,
                    delivery_fee=2.5,
                    cuisine_type="American",
                    is_open=True,
                ),
                Restaurant(
                    name="Sushi Point",
                    image_url="https://picsum.photos/800/600?sushi",
                    rating=4.8,
                    delivery_time_minutes=35,
                    delivery_fee=3.0,
                    cuisine_type="Japanese",
                    is_open=True,
                ),
            ]
            db.add_all(restaurants)
            db.flush()

            db.add_all(
                [
                    MenuItem(
                        restaurant_id=restaurants[0].id,
                        name="Classic Cheeseburger",
                        description="Beef patty, cheddar, lettuce, tomato",
                        category="Burgers",
                        price=8.99,
                        image_url="https://picsum.photos/600/400?cheeseburger",
                        is_available=True,
                    ),
                    MenuItem(
                        restaurant_id=restaurants[0].id,
                        name="Crispy Fries",
                        description="Golden potato fries with house seasoning",
                        category="Sides",
                        price=3.49,
                        image_url="https://picsum.photos/600/400?fries",
                        is_available=True,
                    ),
                    MenuItem(
                        restaurant_id=restaurants[1].id,
                        name="Salmon Nigiri",
                        description="Fresh salmon over seasoned rice",
                        category="Sushi",
                        price=12.5,
                        image_url="https://picsum.photos/600/400?salmon",
                        is_available=True,
                    ),
                    MenuItem(
                        restaurant_id=restaurants[1].id,
                        name="California Roll",
                        description="Crab, avocado, cucumber",
                        category="Rolls",
                        price=9.75,
                        image_url="https://picsum.photos/600/400?roll",
                        is_available=True,
                    ),
                ]
            )

        db.commit()
        print("Seed completed successfully")
    finally:
        db.close()


if __name__ == "__main__":
    run_seed()
