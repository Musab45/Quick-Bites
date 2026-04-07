from database import SessionLocal, init_db
from models import MenuItem, Order, OrderItem, OrderStatus, Restaurant, User
from security import hash_password


RESTAURANT_SEED = [
    {
        "name": "Burger Hub",
        "image_url": "https://picsum.photos/800/600?burger",
        "rating": 4.6,
        "delivery_time_minutes": 25,
        "delivery_fee": 2.5,
        "cuisine_type": "American",
        "is_open": True,
    },
    {
        "name": "Sushi Point",
        "image_url": "https://picsum.photos/800/600?sushi",
        "rating": 4.8,
        "delivery_time_minutes": 34,
        "delivery_fee": 3.0,
        "cuisine_type": "Japanese",
        "is_open": True,
    },
    {
        "name": "Napoli Fire Pizza",
        "image_url": "https://picsum.photos/800/600?pizza",
        "rating": 4.7,
        "delivery_time_minutes": 28,
        "delivery_fee": 1.99,
        "cuisine_type": "Pizza",
        "is_open": True,
    },
    {
        "name": "Green Garden Bowls",
        "image_url": "https://picsum.photos/800/600?salad",
        "rating": 4.5,
        "delivery_time_minutes": 22,
        "delivery_fee": 0.0,
        "cuisine_type": "Healthy",
        "is_open": True,
    },
    {
        "name": "Dragon Wok",
        "image_url": "https://picsum.photos/800/600?noodles",
        "rating": 4.4,
        "delivery_time_minutes": 30,
        "delivery_fee": 2.25,
        "cuisine_type": "Chinese",
        "is_open": True,
    },
    {
        "name": "Taco Loco",
        "image_url": "https://picsum.photos/800/600?taco",
        "rating": 4.6,
        "delivery_time_minutes": 24,
        "delivery_fee": 1.75,
        "cuisine_type": "Mexican",
        "is_open": True,
    },
    {
        "name": "Curry District",
        "image_url": "https://picsum.photos/800/600?curry",
        "rating": 4.7,
        "delivery_time_minutes": 33,
        "delivery_fee": 2.99,
        "cuisine_type": "Indian",
        "is_open": True,
    },
    {
        "name": "Le Petit Bistro",
        "image_url": "https://picsum.photos/800/600?bistro",
        "rating": 4.9,
        "delivery_time_minutes": 38,
        "delivery_fee": 3.5,
        "cuisine_type": "French",
        "is_open": False,
    },
    {
        "name": "Seoul Bites",
        "image_url": "https://picsum.photos/800/600?korean",
        "rating": 4.5,
        "delivery_time_minutes": 29,
        "delivery_fee": 2.4,
        "cuisine_type": "Korean",
        "is_open": True,
    },
    {
        "name": "Pasta Atelier",
        "image_url": "https://picsum.photos/800/600?pasta",
        "rating": 4.8,
        "delivery_time_minutes": 31,
        "delivery_fee": 2.2,
        "cuisine_type": "Italian",
        "is_open": True,
    },
    {
        "name": "Morning Brew Cafe",
        "image_url": "https://picsum.photos/800/600?coffee",
        "rating": 4.3,
        "delivery_time_minutes": 16,
        "delivery_fee": 0.99,
        "cuisine_type": "Cafe",
        "is_open": True,
    },
    {
        "name": "Sweet Theory",
        "image_url": "https://picsum.photos/800/600?dessert",
        "rating": 4.7,
        "delivery_time_minutes": 20,
        "delivery_fee": 1.25,
        "cuisine_type": "Desserts",
        "is_open": True,
    },
]


def _menu_for(cuisine: str) -> list[dict[str, str | float | bool]]:
    templates: dict[str, list[dict[str, str | float | bool]]] = {
        "American": [
            {"category": "Burgers", "name": "Classic Cheeseburger", "description": "Beef patty, cheddar, lettuce, tomato", "price": 8.99, "image": "cheeseburger"},
            {"category": "Burgers", "name": "Smoky Double Stack", "description": "Double beef, bacon jam, pickles, onion", "price": 11.49, "image": "burger"},
            {"category": "Sides", "name": "Crispy Fries", "description": "Golden fries with sea salt", "price": 3.49, "image": "fries"},
            {"category": "Sides", "name": "Loaded Waffle Fries", "description": "Cheese sauce, spring onion, jalapeno", "price": 5.75, "image": "waffle-fries"},
            {"category": "Drinks", "name": "Vanilla Milkshake", "description": "Thick shake with whipped cream", "price": 4.95, "image": "milkshake"},
            {"category": "Desserts", "name": "Chocolate Brownie", "description": "Warm brownie with fudge drizzle", "price": 4.25, "image": "brownie"},
        ],
        "Japanese": [
            {"category": "Sushi", "name": "Salmon Nigiri", "description": "Fresh salmon over seasoned rice", "price": 12.50, "image": "salmon"},
            {"category": "Rolls", "name": "California Roll", "description": "Crab, avocado, cucumber", "price": 9.75, "image": "roll"},
            {"category": "Rolls", "name": "Spicy Tuna Roll", "description": "Tuna, chili mayo, cucumber", "price": 10.95, "image": "tuna-roll"},
            {"category": "Bowls", "name": "Teriyaki Chicken Bowl", "description": "Grilled chicken, rice, sesame", "price": 11.99, "image": "teriyaki"},
            {"category": "Soup", "name": "Miso Soup", "description": "Tofu, seaweed, spring onion", "price": 3.99, "image": "miso"},
            {"category": "Drinks", "name": "Matcha Latte", "description": "Iced matcha with milk", "price": 5.25, "image": "matcha"},
        ],
        "Pizza": [
            {"category": "Pizza", "name": "Margherita", "description": "Tomato, mozzarella, basil", "price": 13.50, "image": "margherita"},
            {"category": "Pizza", "name": "Pepperoni Blaze", "description": "Pepperoni, mozzarella, oregano", "price": 15.25, "image": "pepperoni"},
            {"category": "Pizza", "name": "Truffle Mushroom", "description": "Mushroom mix, truffle oil, parmesan", "price": 16.95, "image": "mushroom-pizza"},
            {"category": "Sides", "name": "Garlic Knots", "description": "Soft knots with garlic butter", "price": 5.20, "image": "garlic-bread"},
            {"category": "Salads", "name": "Caesar Salad", "description": "Romaine, parmesan, croutons", "price": 7.50, "image": "caesar"},
            {"category": "Drinks", "name": "Sparkling Lemonade", "description": "House lemonade with bubbles", "price": 3.95, "image": "lemonade"},
        ],
    }

    fallback = [
        {"category": "Mains", "name": f"{cuisine} Signature Plate", "description": f"Chef-crafted {cuisine.lower()} special", "price": 13.95, "image": cuisine.lower()},
        {"category": "Mains", "name": f"{cuisine} Classic", "description": "A house favorite made fresh", "price": 11.50, "image": f"{cuisine.lower()}-classic"},
        {"category": "Mains", "name": f"Spicy {cuisine} Bowl", "description": "Balanced heat and flavor", "price": 12.75, "image": f"spicy-{cuisine.lower()}"},
        {"category": "Sides", "name": "Crispy Side Basket", "description": "Crispy shareable side", "price": 4.80, "image": "sides"},
        {"category": "Desserts", "name": "House Dessert", "description": "Daily sweet special", "price": 5.10, "image": "dessert"},
        {"category": "Drinks", "name": "Signature Cooler", "description": "Refreshing non-alcoholic drink", "price": 3.90, "image": "drink"},
    ]
    return templates.get(cuisine, fallback)


def _seed_demo_orders(db: SessionLocal, demo_user: User) -> None:
    if db.query(Order).filter(Order.user_id == demo_user.id).count() > 0:
        return

    restaurants = db.query(Restaurant).order_by(Restaurant.id.asc()).all()
    restaurant_by_name = {restaurant.name: restaurant for restaurant in restaurants}

    plans = [
        {
            "restaurant": "Burger Hub",
            "status": OrderStatus.delivered.value,
            "address": "123 Mission Street, San Francisco",
            "payment_method": "card",
            "estimated": 26,
            "items": [(0, 2), (2, 1)],
        },
        {
            "restaurant": "Sushi Point",
            "status": OrderStatus.on_the_way.value,
            "address": "88 Market Street, San Francisco",
            "payment_method": "card",
            "estimated": 18,
            "items": [(0, 1), (1, 2)],
        },
        {
            "restaurant": "Napoli Fire Pizza",
            "status": OrderStatus.preparing.value,
            "address": "456 Howard Street, San Francisco",
            "payment_method": "cash",
            "estimated": 24,
            "items": [(1, 1), (3, 1)],
        },
        {
            "restaurant": "Green Garden Bowls",
            "status": OrderStatus.confirmed.value,
            "address": "91 Pine Street, San Francisco",
            "payment_method": "wallet",
            "estimated": 17,
            "items": [(0, 1), (5, 1)],
        },
        {
            "restaurant": "Dragon Wok",
            "status": OrderStatus.pending.value,
            "address": "72 Howard Street, San Francisco",
            "payment_method": "card",
            "estimated": 29,
            "items": [(0, 1), (2, 1)],
        },
        {
            "restaurant": "Curry District",
            "status": OrderStatus.cancelled.value,
            "address": "18 Main Street, San Francisco",
            "payment_method": "card",
            "estimated": 35,
            "items": [(0, 1), (1, 1)],
        },
        {
            "restaurant": "Pasta Atelier",
            "status": OrderStatus.delivered.value,
            "address": "14 Folsom Street, San Francisco",
            "payment_method": "wallet",
            "estimated": 27,
            "items": [(0, 2), (4, 1)],
        },
        {
            "restaurant": "Sweet Theory",
            "status": OrderStatus.delivered.value,
            "address": "201 Fremont Street, San Francisco",
            "payment_method": "cash",
            "estimated": 15,
            "items": [(0, 1), (4, 1)],
        },
    ]

    for plan in plans:
        restaurant = restaurant_by_name.get(plan["restaurant"])
        if restaurant is None:
            continue

        menu_items = (
            db.query(MenuItem)
            .filter(MenuItem.restaurant_id == restaurant.id)
            .order_by(MenuItem.id.asc())
            .all()
        )
        if not menu_items:
            continue

        order_items: list[OrderItem] = []
        total = 0.0
        for index, quantity in plan["items"]:
            menu_item = menu_items[index % len(menu_items)]
            line_total = menu_item.price * quantity
            total += line_total
            order_items.append(
                OrderItem(
                    menu_item_id=menu_item.id,
                    name=menu_item.name,
                    quantity=quantity,
                    unit_price=menu_item.price,
                    line_total=round(line_total, 2),
                )
            )

        db.add(
            Order(
                user_id=demo_user.id,
                restaurant_id=restaurant.id,
                address=plan["address"],
                payment_method=plan["payment_method"],
                status=plan["status"],
                total_amount=round(total, 2),
                estimated_delivery_minutes=plan["estimated"],
                items=order_items,
            )
        )


def run_seed() -> None:
    init_db()
    db = SessionLocal()
    try:
        demo_user = db.query(User).filter(User.email == "demo@quickbite.dev").first()
        if demo_user is None:
            demo_user = User(
                email="demo@quickbite.dev",
                full_name="Demo User",
                password_hash=hash_password("DemoPass123"),
            )
            db.add(demo_user)
            db.flush()

        for payload in RESTAURANT_SEED:
            restaurant = db.query(Restaurant).filter(Restaurant.name == payload["name"]).first()
            if restaurant is None:
                restaurant = Restaurant(**payload)
                db.add(restaurant)
                db.flush()

            existing_names = {
                item.name
                for item in db.query(MenuItem)
                .filter(MenuItem.restaurant_id == restaurant.id)
                .all()
            }
            payloads = _menu_for(restaurant.cuisine_type)
            to_add = [
                MenuItem(
                    restaurant_id=restaurant.id,
                    name=str(item["name"]),
                    description=str(item["description"]),
                    category=str(item["category"]),
                    price=float(item["price"]),
                    image_url=f"https://picsum.photos/600/400?{item['image']}",
                    is_available=bool(item.get("is_available", True)),
                )
                for item in payloads
                if str(item["name"]) not in existing_names
            ]
            if to_add:
                db.add_all(to_add)

        _seed_demo_orders(db, demo_user)
        db.commit()
        print("Seed completed successfully")
    finally:
        db.close()


if __name__ == "__main__":
    run_seed()
