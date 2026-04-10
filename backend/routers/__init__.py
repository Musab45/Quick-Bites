from routers.auth import router as auth_router
from routers.menu import router as menu_router
from routers.orders import router as orders_router
from routers.payment_cards import router as payment_cards_router
from routers.restaurants import router as restaurants_router
from routers.wallet import router as wallet_router

__all__ = [
	"auth_router",
	"restaurants_router",
	"menu_router",
	"orders_router",
	"payment_cards_router",
	"wallet_router",
]
