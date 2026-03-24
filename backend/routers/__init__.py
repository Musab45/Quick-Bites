from routers.auth import router as auth_router
from routers.menu import router as menu_router
from routers.orders import router as orders_router
from routers.restaurants import router as restaurants_router

__all__ = ["auth_router", "restaurants_router", "menu_router", "orders_router"]
