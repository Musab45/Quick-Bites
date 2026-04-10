from database import SessionLocal, init_db
from image_urls import (
    is_generated_image_url,
    menu_item_image_url,
    restaurant_image_url,
)
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
            {"category": "Burgers", "name": "Mushroom Swiss Burger", "description": "Beef patty, sauteed mushrooms, swiss cheese", "price": 10.99, "image": "mushroom-burger"},
            {"category": "Burgers", "name": "Spicy Jalapeno Burger", "description": "Pepper jack, jalapenos, spicy mayo", "price": 10.49, "image": "spicy-burger"},
            {"category": "Chicken", "name": "Crispy Chicken Sandwich", "description": "Fried chicken breast, pickles, mayo", "price": 9.49, "image": "chicken-sandwich"},
            {"category": "Chicken", "name": "Buffalo Chicken Wings", "description": "8 crispy wings tossed in buffalo sauce", "price": 10.99, "image": "wings"},
            {"category": "Sides", "name": "Crispy Fries", "description": "Golden fries with sea salt", "price": 3.49, "image": "fries"},
            {"category": "Sides", "name": "Loaded Waffle Fries", "description": "Cheese sauce, spring onion, jalapeno", "price": 5.75, "image": "waffle-fries"},
            {"category": "Sides", "name": "Onion Rings", "description": "Beer-battered onion rings with ranch dip", "price": 4.95, "image": "onion-rings"},
            {"category": "Sides", "name": "Mac & Cheese Bites", "description": "Crispy fried mac and cheese", "price": 6.25, "image": "mac-cheese"},
            {"category": "Drinks", "name": "Vanilla Milkshake", "description": "Thick shake with whipped cream", "price": 4.95, "image": "milkshake"},
            {"category": "Drinks", "name": "Strawberry Milkshake", "description": "Classic strawberry shake", "price": 4.95, "image": "strawberry-shake"},
            {"category": "Drinks", "name": "Iced Tea", "description": "Freshly brewed sweet tea", "price": 2.50, "image": "iced-tea"},
            {"category": "Desserts", "name": "Chocolate Brownie", "description": "Warm brownie with fudge drizzle", "price": 4.25, "image": "brownie"},
            {"category": "Desserts", "name": "Apple Pie", "description": "Slice of traditional apple pie", "price": 4.50, "image": "apple-pie"},
        ],
        "Japanese": [
            {"category": "Sushi", "name": "Salmon Nigiri", "description": "Fresh salmon over seasoned rice", "price": 12.50, "image": "salmon"},
            {"category": "Sushi", "name": "Tuna Nigiri", "description": "Fresh tuna on seasoned rice", "price": 13.00, "image": "tuna"},
            {"category": "Rolls", "name": "California Roll", "description": "Crab, avocado, cucumber", "price": 9.75, "image": "roll"},
            {"category": "Rolls", "name": "Spicy Tuna Roll", "description": "Tuna, chili mayo, cucumber", "price": 10.95, "image": "tuna-roll"},
            {"category": "Rolls", "name": "Dragon Roll", "description": "Eel, cucumber, topped with avocado", "price": 14.50, "image": "dragon-roll"},
            {"category": "Rolls", "name": "Rainbow Roll", "description": "Crab stick, avocado, topped with assorted fish", "price": 15.00, "image": "rainbow-roll"},
            {"category": "Hot Dishes", "name": "Teriyaki Chicken Bowl", "description": "Grilled chicken, rice, sesame", "price": 11.99, "image": "teriyaki"},
            {"category": "Hot Dishes", "name": "Chicken Katsu Curry", "description": "Crispy chicken cutlet with curry sauce", "price": 14.99, "image": "katsu-curry"},
            {"category": "Hot Dishes", "name": "Pork Gyoza", "description": "Pan-fried pork dumplings", "price": 6.50, "image": "gyoza"},
            {"category": "Hot Dishes", "name": "Shrimp Tempura", "description": "Lightly battered fried shrimp", "price": 8.99, "image": "tempura"},
            {"category": "Soup & Salad", "name": "Miso Soup", "description": "Tofu, seaweed, spring onion", "price": 3.99, "image": "miso"},
            {"category": "Soup & Salad", "name": "Wakame Salad", "description": "Seasoned seaweed salad", "price": 5.50, "image": "seaweed-salad"},
            {"category": "Drinks", "name": "Matcha Latte", "description": "Iced matcha with milk", "price": 5.25, "image": "matcha"},
            {"category": "Drinks", "name": "Ramune", "description": "Japanese sweet soda", "price": 3.50, "image": "ramune"},
            {"category": "Desserts", "name": "Mochi Ice Cream", "description": "3 pieces of assorted mochi", "price": 4.99, "image": "mochi"},
        ],
        "Pizza": [
            {"category": "Classic Pizza", "name": "Margherita", "description": "Tomato, mozzarella, basil", "price": 13.50, "image": "margherita"},
            {"category": "Classic Pizza", "name": "Pepperoni Blaze", "description": "Pepperoni, mozzarella, oregano", "price": 15.25, "image": "pepperoni"},
            {"category": "Classic Pizza", "name": "Cheese Supreme", "description": "Mozzarella, provolone, parmesan, ricotta", "price": 14.50, "image": "cheese-pizza"},
            {"category": "Specialty Pizza", "name": "Truffle Mushroom", "description": "Mushroom mix, truffle oil, parmesan", "price": 16.95, "image": "mushroom-pizza"},
            {"category": "Specialty Pizza", "name": "BBQ Chicken", "description": "BBQ sauce, grilled chicken, red onions", "price": 16.50, "image": "bbq-chicken-pizza"},
            {"category": "Specialty Pizza", "name": "Meat Lover's", "description": "Sausage, pepperoni, bacon, ham", "price": 18.00, "image": "meat-pizza"},
            {"category": "Specialty Pizza", "name": "Hawaiian", "description": "Pineapple, ham, mozzarella", "price": 15.50, "image": "hawaiian"},
            {"category": "Sides", "name": "Garlic Knots", "description": "Soft knots with garlic butter", "price": 5.20, "image": "garlic-bread"},
            {"category": "Sides", "name": "Mozzarella Sticks", "description": "Breaded cheese with marinara dip", "price": 6.99, "image": "mozzarella-sticks"},
            {"category": "Sides", "name": "Chicken Parmesan Bites", "description": "Bite-sized crispy chicken with marinara", "price": 8.50, "image": "chicken-bites"},
            {"category": "Salads", "name": "Caesar Salad", "description": "Romaine, parmesan, croutons", "price": 7.50, "image": "caesar"},
            {"category": "Salads", "name": "Greek Salad", "description": "Tomatoes, olives, feta, red onions", "price": 8.00, "image": "greek-salad"},
            {"category": "Drinks", "name": "Sparkling Lemonade", "description": "House lemonade with bubbles", "price": 3.95, "image": "lemonade"},
            {"category": "Desserts", "name": "Cinna-Knots", "description": "Knots covered in cinnamon sugar", "price": 4.50, "image": "cinnamon-knots"},
            {"category": "Desserts", "name": "Gelato Cup", "description": "Italian style ice cream", "price": 4.95, "image": "gelato"},
        ],
        "Healthy": [
            {"category": "Bowls", "name": "Quinoa Power Bowl", "description": "Quinoa, roasted sweet potato, kale, avocado", "price": 12.95, "image": "quinoa-bowl"},
            {"category": "Bowls", "name": "Harvest Chicken Bowl", "description": "Grilled chicken, brown rice, broccoli", "price": 14.50, "image": "chicken-bowl"},
            {"category": "Bowls", "name": "Tofu Zen Bowl", "description": "Organic tofu, edamame, wild rice, sesame dressing", "price": 13.50, "image": "tofu-bowl"},
            {"category": "Salads", "name": "Mediterranean Salad", "description": "Mixed greens, feta, olives, cucumber", "price": 10.95, "image": "themed-salad"},
            {"category": "Salads", "name": "Kale & Berry Salad", "description": "Baby kale, strawberries, almonds, vinaigrette", "price": 11.50, "image": "kale-salad"},
            {"category": "Salads", "name": "Avocado Chicken Salad", "description": "Grilled chicken, avocado, mixed greens", "price": 13.95, "image": "avocado-salad"},
            {"category": "Wraps", "name": "Vegan Hummus Wrap", "description": "Hummus, spinach, bell peppers in spinach wrap", "price": 9.50, "image": "hummus-wrap"},
            {"category": "Wraps", "name": "Turkey Avocado Wrap", "description": "Roasted turkey, avocado, whole wheat wrap", "price": 10.50, "image": "turkey-wrap"},
            {"category": "Smoothies", "name": "Green Detox Smoothie", "description": "Spinach, apple, ginger, lemon", "price": 6.50, "image": "green-smoothie"},
            {"category": "Smoothies", "name": "Berry Blast Smoothie", "description": "Mixed berries, banana, almond milk", "price": 6.50, "image": "berry-smoothie"},
            {"category": "Smoothies", "name": "Protein Peanut Butter", "description": "Peanut butter, banana, whey protein", "price": 7.50, "image": "pb-smoothie"},
            {"category": "Drinks", "name": "Kombucha", "description": "Fermented probiotic tea", "price": 4.00, "image": "kombucha"},
            {"category": "Drinks", "name": "Fresh Orange Juice", "description": "Cold pressed oranges", "price": 4.50, "image": "orange-juice"},
            {"category": "Snacks", "name": "Energy Bites", "description": "Oat and peanut butter energy balls", "price": 3.50, "image": "energy-bites"},
            {"category": "Snacks", "name": "Fruit Cup", "description": "Seasonal cut fruits", "price": 4.50, "image": "fruit-cup"},
        ],
        "Chinese": [
            {"category": "Poultry", "name": "Kung Pao Chicken", "description": "Spicy chicken, peanuts, vegetables", "price": 13.99, "image": "kung-pao"},
            {"category": "Poultry", "name": "General Tso's Chicken", "description": "Sweet and slightly spicy fried chicken", "price": 14.50, "image": "general-tsos"},
            {"category": "Poultry", "name": "Orange Chicken", "description": "Crispy chicken in a sweet orange glaze", "price": 14.50, "image": "orange-chicken"},
            {"category": "Beef & Pork", "name": "Beef and Broccoli", "description": "Sliced beef, broccoli, savory brown sauce", "price": 14.99, "image": "beef-broccoli"},
            {"category": "Beef & Pork", "name": "Sweet & Sour Pork", "description": "Crispy pork in classic sweet and sour sauce", "price": 13.50, "image": "sweet-sour-pork"},
            {"category": "Noodles", "name": "Vegetable Chow Mein", "description": "Stir-fried noodles with mixed vegetables", "price": 11.50, "image": "chow-mein"},
            {"category": "Noodles", "name": "Chicken Lo Mein", "description": "Soft noodles tossed with chicken and veggies", "price": 12.50, "image": "lo-mein"},
            {"category": "Rice", "name": "Egg Fried Rice", "description": "Classic fried rice with egg and peas", "price": 5.99, "image": "fried-rice"},
            {"category": "Rice", "name": "House Special Fried Rice", "description": "Shrimp, chicken, pork, and veggies in rice", "price": 13.99, "image": "special-rice"},
            {"category": "Appetizers", "name": "Pork Dumplings", "description": "Pan-fried pork dumplings with soy dip", "price": 7.50, "image": "dumplings"},
            {"category": "Appetizers", "name": "Spring Rolls", "description": "Crispy vegetable spring rolls", "price": 4.99, "image": "spring-rolls"},
            {"category": "Appetizers", "name": "Crab Rangoon", "description": "Crispy wontons filled with cream cheese and crab", "price": 6.50, "image": "crab-rangoon"},
            {"category": "Soup", "name": "Hot & Sour Soup", "description": "Traditional spicy and tangy broth", "price": 4.50, "image": "hot-sour-soup"},
            {"category": "Drinks", "name": "Jasmine Tea", "description": "Hot brewed jasmine green tea", "price": 2.50, "image": "jasmine-tea"},
            {"category": "Desserts", "name": "Sesame Balls", "description": "Fried dough filled with red bean paste", "price": 4.50, "image": "sesame-balls"},
        ],
        "Mexican": [
            {"category": "Tacos", "name": "Al Pastor Tacos", "description": "Marinated pork, pineapple, cilantro, onion", "price": 10.50, "image": "al-pastor"},
            {"category": "Tacos", "name": "Carne Asada Tacos", "description": "Grilled steak, guacamole, pico de gallo", "price": 12.00, "image": "carne-asada"},
            {"category": "Tacos", "name": "Baja Fish Tacos", "description": "Fried fish, cabbage slaw, chipotle mayo", "price": 11.50, "image": "fish-tacos"},
            {"category": "Tacos", "name": "Chicken Tinga Tacos", "description": "Shredded spiced chicken with fixings", "price": 10.00, "image": "tinga-tacos"},
            {"category": "Burritos", "name": "Chicken Burrito", "description": "Rice, beans, grilled chicken, cheese, salsa", "price": 11.95, "image": "burrito"},
            {"category": "Burritos", "name": "California Burrito", "description": "Steak, french fries, cheese, guacamole", "price": 13.50, "image": "cali-burrito"},
            {"category": "Burritos", "name": "Veggie Bean Burrito", "description": "Black beans, peppers, rice, vegan cheese", "price": 10.50, "image": "veggie-burrito"},
            {"category": "Quesadillas", "name": "Cheese Quesadilla", "description": "Flour tortilla with melted cheese blend", "price": 8.50, "image": "quesadilla"},
            {"category": "Quesadillas", "name": "Steak Quesadilla", "description": "Melted cheese and grilled steak", "price": 11.50, "image": "steak-quesadilla"},
            {"category": "Sides", "name": "Chips and Guacamole", "description": "House-made tortilla chips with fresh guac", "price": 6.99, "image": "guacamole"},
            {"category": "Sides", "name": "Queso Dip", "description": "Warm melted cheese dip with chips", "price": 5.99, "image": "queso"},
            {"category": "Sides", "name": "Mexican Street Corn", "description": "Elote with mayo, cotija, chili powder", "price": 4.50, "image": "elote"},
            {"category": "Drinks", "name": "Horchata", "description": "Sweet rice milk with cinnamon", "price": 3.50, "image": "horchata"},
            {"category": "Drinks", "name": "Jamaica", "description": "Hibiscus iced tea", "price": 3.00, "image": "jamaica"},
            {"category": "Desserts", "name": "Churros", "description": "Fried dough pastry with cinnamon sugar", "price": 5.00, "image": "churros"},
        ],
        "Indian": [
            {"category": "Curries", "name": "Chicken Tikka Masala", "description": "Roasted chicken chunks in spicy sauce", "price": 15.99, "image": "tikka-masala"},
            {"category": "Curries", "name": "Butter Chicken", "description": "Chicken in a mild, creamy tomato curry", "price": 16.50, "image": "butter-chicken"},
            {"category": "Curries", "name": "Lamb Vindaloo", "description": "Spicy curry with tender lamb pieces", "price": 18.00, "image": "vindaloo"},
            {"category": "Vegetarian", "name": "Palak Paneer", "description": "Cottage cheese in thick spinach purée", "price": 14.50, "image": "palak-paneer"},
            {"category": "Vegetarian", "name": "Chana Masala", "description": "Chickpeas simmered in spiced tomato gravy", "price": 13.00, "image": "chana-masala"},
            {"category": "Vegetarian", "name": "Aloo Gobi", "description": "Potatoes and cauliflower stewed with spices", "price": 13.50, "image": "aloo-gobi"},
            {"category": "Biryanis", "name": "Lamb Biryani", "description": "Basmati rice cooked with marinated lamb", "price": 17.50, "image": "biryani"},
            {"category": "Biryanis", "name": "Chicken Biryani", "description": "Spiced rice mixed with flavorful chicken", "price": 16.00, "image": "chicken-biryani"},
            {"category": "Breads", "name": "Garlic Naan", "description": "Flatbread topped with garlic and butter", "price": 3.99, "image": "garlic-naan"},
            {"category": "Breads", "name": "Plain Naan", "description": "Traditional oven-baked flatbread", "price": 3.00, "image": "naan"},
            {"category": "Breads", "name": "Cheese Naan", "description": "Flatbread stuffed with melted cheese", "price": 4.50, "image": "cheese-naan"},
            {"category": "Sides", "name": "Vegetable Samosa", "description": "Fried pastry with savory filling", "price": 5.50, "image": "samosa"},
            {"category": "Sides", "name": "Onion Bhaji", "description": "Crispy fried onion fritters", "price": 5.00, "image": "bhaji"},
            {"category": "Drinks", "name": "Mango Lassi", "description": "Yogurt-based mango drink", "price": 4.50, "image": "mango-lassi"},
            {"category": "Desserts", "name": "Gulab Jamun", "description": "Milk dough balls in sweet syrup", "price": 4.99, "image": "gulab-jamun"},
        ],
        "French": [
            {"category": "Appetizers", "name": "French Onion Soup", "description": "Beef broth, caramelized onions, gruyere", "price": 9.50, "image": "onion-soup"},
            {"category": "Appetizers", "name": "Escargots", "description": "Snails baked with garlic butter", "price": 12.00, "image": "escargot"},
            {"category": "Appetizers", "name": "Baked Brie", "description": "Warm brie served with baguette", "price": 11.50, "image": "baked-brie"},
            {"category": "Mains", "name": "Coq au Vin", "description": "Chicken braised with wine, mushrooms, garlic", "price": 22.00, "image": "coq-au-vin"},
            {"category": "Mains", "name": "Beef Bourguignon", "description": "Beef stewed in red wine, pearl onions", "price": 24.50, "image": "beef-bourguignon"},
            {"category": "Mains", "name": "Duck Confit", "description": "Slow-cooked duck leg with potatoes", "price": 26.00, "image": "duck-confit"},
            {"category": "Mains", "name": "Steak Frites", "description": "Pan-seared steak with french fries", "price": 28.00, "image": "steak-frites"},
            {"category": "Sides", "name": "Ratatouille", "description": "Stewed vegetable dish", "price": 12.00, "image": "ratatouille"},
            {"category": "Sides", "name": "Pommes Frites", "description": "Classic French fries", "price": 6.00, "image": "pommes-frites"},
            {"category": "Sides", "name": "Gratin Dauphinois", "description": "Scalloped potatoes with cream and cheese", "price": 9.00, "image": "gratin"},
            {"category": "Desserts", "name": "Crème Brûlée", "description": "Rich custard topped with caramelized sugar", "price": 8.50, "image": "creme-brulee"},
            {"category": "Desserts", "name": "Macarons", "description": "Assorted French macarons", "price": 7.00, "image": "macarons"},
            {"category": "Desserts", "name": "Chocolate Soufflé", "description": "Warm dark chocolate souffle", "price": 9.50, "image": "souffle"},
            {"category": "Drinks", "name": "Perrier Water", "description": "Sparkling mineral water", "price": 3.00, "image": "perrier"},
            {"category": "Drinks", "name": "Café au Lait", "description": "Coffee with hot milk", "price": 4.50, "image": "cafe-lait"},
        ],
        "Korean": [
            {"category": "Mains", "name": "Bibimbap", "description": "Mixed rice with meat and assorted vegetables", "price": 14.50, "image": "bibimbap"},
            {"category": "Mains", "name": "Beef Bulgogi", "description": "Marinated slices of beef grilled to perfection", "price": 17.50, "image": "bulgogi"},
            {"category": "Mains", "name": "Spicy Pork Bulgogi", "description": "Marinated spicy pork thin slices", "price": 16.50, "image": "pork-bulgogi"},
            {"category": "Mains", "name": "Galbi", "description": "Marinated grilled beef short ribs", "price": 22.00, "image": "galbi"},
            {"category": "Noodles", "name": "Japchae", "description": "Stir-fried glass noodles and vegetables", "price": 13.00, "image": "japchae"},
            {"category": "Noodles", "name": "Jajangmyeon", "description": "Noodles with thick black bean sauce", "price": 12.50, "image": "jajangmyeon"},
            {"category": "Soups & Stews", "name": "Kimchi Jjigae", "description": "Spicy kimchi stew with pork", "price": 14.00, "image": "kimchi-stew"},
            {"category": "Soups & Stews", "name": "Sundubu Jjigae", "description": "Spicy soft tofu stew", "price": 13.50, "image": "tofu-stew"},
            {"category": "Snacks", "name": "Tteokbokki", "description": "Spicy stir-fried rice cakes", "price": 11.50, "image": "tteokbokki"},
            {"category": "Snacks", "name": "Gimbap", "description": "Seaweed rice roll", "price": 7.50, "image": "gimbap"},
            {"category": "Snacks", "name": "Haemul Pajeon", "description": "Seafood and green onion pancake", "price": 12.50, "image": "pancake"},
            {"category": "Sides", "name": "Kimchi", "description": "Traditional fermented spicy cabbage", "price": 4.50, "image": "kimchi"},
            {"category": "Appetizers", "name": "Korean Fried Chicken", "description": "Crispy chicken tossed in sweet soy glaze", "price": 16.00, "image": "korean-fried-chicken"},
            {"category": "Drinks", "name": "Soju Sweet Can", "description": "Non-alcoholic sweet soda", "price": 3.50, "image": "sweet-drink"},
            {"category": "Desserts", "name": "Bingsu", "description": "Shaved ice with sweet toppings", "price": 8.00, "image": "bingsu"},
        ],
        "Italian": [
            {"category": "Pasta", "name": "Spaghetti Carbonara", "description": "Pasta with egg, hard cheese, cured pork", "price": 15.50, "image": "carbonara"},
            {"category": "Pasta", "name": "Fettuccine Alfredo", "description": "Fresh pasta tossed with butter and parmesan", "price": 14.00, "image": "alfredo"},
            {"category": "Pasta", "name": "Penne Arrabbiata", "description": "Pasta in a spicy tomato sauce", "price": 13.50, "image": "arrabbiata"},
            {"category": "Pasta", "name": "Lasagna Bolognese", "description": "Layers of pasta, meat sauce, and cheese", "price": 16.50, "image": "lasagna"},
            {"category": "Pasta", "name": "Spinach Ravioli", "description": "Stuffed pasta with spinach and ricotta", "price": 15.00, "image": "ravioli"},
            {"category": "Mains", "name": "Chicken Parmesan", "description": "Breaded chicken breast with tomato sauce and mozzarella", "price": 18.50, "image": "chicken-parmesan"},
            {"category": "Mains", "name": "Veal Marsala", "description": "Veal cutlets in a rich marsala wine sauce", "price": 22.00, "image": "veal-marsala"},
            {"category": "Mains", "name": "Eggplant Parmesan", "description": "Breaded eggplant baked with marinara and cheese", "price": 16.00, "image": "eggplant-parm"},
            {"category": "Salads", "name": "Caprese Salad", "description": "Sliced fresh mozzarella, tomatoes, and sweet basil", "price": 11.00, "image": "caprese"},
            {"category": "Salads", "name": "Antipasto Misto", "description": "Cured meats, cheeses, and olives", "price": 14.50, "image": "antipasto"},
            {"category": "Sides", "name": "Bruschetta", "description": "Grilled bread rubbed with garlic and topped with tomatoes", "price": 8.50, "image": "bruschetta"},
            {"category": "Sides", "name": "Garlic Bread", "description": "Toasted bread with garlic butter", "price": 5.00, "image": "garlic-bread"},
            {"category": "Desserts", "name": "Tiramisu", "description": "Coffee-flavoured Italian dessert", "price": 7.50, "image": "tiramisu"},
            {"category": "Desserts", "name": "Cannoli", "description": "Pastry tubes filled with sweet ricotta", "price": 6.00, "image": "cannoli"},
            {"category": "Drinks", "name": "San Pellegrino", "description": "Sparkling water", "price": 3.00, "image": "pellegrino"},
        ],
        "Cafe": [
            {"category": "Coffee", "name": "Cappuccino", "description": "Espresso, hot milk, and steamed milk foam", "price": 4.50, "image": "cappuccino"},
            {"category": "Coffee", "name": "Caramel Macchiato", "description": "Espresso with vanilla-flavored syrup and milk", "price": 5.00, "image": "macchiato"},
            {"category": "Coffee", "name": "Caffe Latte", "description": "Espresso with lots of steamed milk", "price": 4.25, "image": "latte"},
            {"category": "Coffee", "name": "Americano", "description": "Espresso poured over hot water", "price": 3.50, "image": "americano"},
            {"category": "Coffee", "name": "Espresso", "description": "Single shot of strong black coffee", "price": 2.50, "image": "espresso"},
            {"category": "Tea", "name": "Earl Grey Tea", "description": "Classic black tea with bergamot", "price": 3.75, "image": "earl-grey"},
            {"category": "Tea", "name": "Chai Tea Latte", "description": "Spiced black tea with steamed milk", "price": 4.50, "image": "chai-latte"},
            {"category": "Pastries", "name": "Butter Croissant", "description": "Flaky, buttery French pastry", "price": 3.50, "image": "croissant"},
            {"category": "Pastries", "name": "Chocolate Croissant", "description": "Croissant stuffed with dark chocolate", "price": 4.00, "image": "choc-croissant"},
            {"category": "Pastries", "name": "Blueberry Muffin", "description": "Freshly baked muffin with blueberries", "price": 3.25, "image": "muffin"},
            {"category": "Sandwiches", "name": "Turkey Club", "description": "Turkey, bacon, lettuce, tomato on whole wheat", "price": 9.50, "image": "turkey-club"},
            {"category": "Sandwiches", "name": "BLT Sandwich", "description": "Bacon, lettuce, tomato with mayo", "price": 8.50, "image": "blt"},
            {"category": "Sandwiches", "name": "Caprese Panini", "description": "Mozzarella, tomato, basil pesto panini", "price": 9.00, "image": "panini"},
            {"category": "Breakfast", "name": "Avocado Toast", "description": "Mashed avocado on toasted artisan bread", "price": 8.00, "image": "avocado-toast"},
            {"category": "Breakfast", "name": "Oatmeal Bowl", "description": "Warm oats with honey and berries", "price": 6.50, "image": "oatmeal"},
        ],
        "Desserts": [
            {"category": "Cakes", "name": "New York Cheesecake", "description": "Classic dense and rich cream cheese cake", "price": 7.50, "image": "cheesecake"},
            {"category": "Cakes", "name": "Red Velvet Cake", "description": "Layer cake with cream cheese icing", "price": 8.00, "image": "red-velvet"},
            {"category": "Cakes", "name": "Chocolate Lava Cake", "description": "Warm cake with a gooey chocolate center", "price": 9.00, "image": "lava-cake"},
            {"category": "Cakes", "name": "Carrot Cake", "description": "Spiced cake with cream cheese frosting", "price": 7.50, "image": "carrot-cake"},
            {"category": "Ice Cream", "name": "Vanilla Bean Gelato", "description": "Italian style vanilla ice cream", "price": 5.50, "image": "gelato"},
            {"category": "Ice Cream", "name": "Strawberry Sorbet", "description": "Refreshing dairy-free strawberry treat", "price": 5.00, "image": "sorbet"},
            {"category": "Ice Cream", "name": "Mint Chocolate Chip", "description": "Mint ice cream with dark chocolate chips", "price": 5.50, "image": "mint-choc-chip"},
            {"category": "Ice Cream", "name": "Banana Split", "description": "Three scoops of ice cream with toppings", "price": 8.50, "image": "banana-split"},
            {"category": "Pastries", "name": "Chocolate Éclair", "description": "Choux pastry filled with cream and topped with chocolate", "price": 4.50, "image": "eclair"},
            {"category": "Pastries", "name": "Fruit Tart", "description": "Pastry shell filled with custard and fresh fruit", "price": 5.50, "image": "fruit-tart"},
            {"category": "Cookies", "name": "Chocolate Chip Cookie", "description": "Warm, chewy freshly baked cookie", "price": 3.00, "image": "cookie"},
            {"category": "Cookies", "name": "Peanut Butter Cookie", "description": "Soft cookie with peanut chunks", "price": 3.00, "image": "pb-cookie"},
            {"category": "Cookies", "name": "Macadamia Nut Cookie", "description": "Soft cookie with white chocolate and macadamia", "price": 3.50, "image": "macadamia"},
            {"category": "Drinks", "name": "Mocha Frappuccino", "description": "Blended iced coffee drink with chocolate", "price": 5.50, "image": "frappuccino"},
            {"category": "Drinks", "name": "Hot Chocolate", "description": "Rich hot cocoa with marshmallows", "price": 4.00, "image": "hot-chocolate"},
        ]
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
            target_restaurant_image = restaurant_image_url(
                str(payload["name"]),
                str(payload["cuisine_type"]),
            )
            if restaurant is None:
                restaurant_payload = dict(payload)
                restaurant_payload["image_url"] = target_restaurant_image
                restaurant = Restaurant(**restaurant_payload)
                db.add(restaurant)
                db.flush()
            elif (
                is_generated_image_url(restaurant.image_url)
                and restaurant.image_url != target_restaurant_image
            ):
                restaurant.image_url = target_restaurant_image

            existing_menu_items = (
                db.query(MenuItem)
                .filter(MenuItem.restaurant_id == restaurant.id)
                .all()
            )
            existing_names = {item.name for item in existing_menu_items}

            for existing_item in existing_menu_items:
                target_item_image = menu_item_image_url(
                    existing_item.name,
                    existing_item.category,
                    restaurant.cuisine_type,
                )
                if (
                    is_generated_image_url(existing_item.image_url)
                    and existing_item.image_url != target_item_image
                ):
                    existing_item.image_url = target_item_image

            payloads = _menu_for(restaurant.cuisine_type)
            to_add = [
                MenuItem(
                    restaurant_id=restaurant.id,
                    name=str(item["name"]),
                    description=str(item["description"]),
                    category=str(item["category"]),
                    price=float(item["price"]),
                    image_url=menu_item_image_url(
                        str(item["name"]),
                        str(item["category"]),
                        restaurant.cuisine_type,
                    ),
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
