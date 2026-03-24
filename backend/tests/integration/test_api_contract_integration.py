from fastapi.testclient import TestClient

from main import app
from seed import run_seed

client = TestClient(app)


def test_auth_and_order_flow() -> None:
    run_seed()

    register_response = client.post(
        "/auth/register",
        json={
            "email": "flow_user@quickbite.dev",
            "full_name": "Flow User",
            "password": "FlowPass123",
        },
    )
    assert register_response.status_code in (201, 409)

    login_response = client.post(
        "/auth/login",
        json={"email": "flow_user@quickbite.dev", "password": "FlowPass123"},
    )
    assert login_response.status_code == 200
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    restaurants_response = client.get("/restaurants")
    assert restaurants_response.status_code == 200
    restaurants = restaurants_response.json()
    assert len(restaurants) > 0

    restaurant_id = restaurants[0]["id"]
    menu_response = client.get(f"/menu/{restaurant_id}")
    assert menu_response.status_code == 200
    grouped_menu = menu_response.json()

    first_category = next(iter(grouped_menu.keys()))
    first_item = grouped_menu[first_category][0]

    create_order_response = client.post(
        "/orders",
        headers=headers,
        json={
            "restaurant_id": restaurant_id,
            "address": "123 Test Street",
            "payment_method": "card",
            "items": [{"menu_item_id": first_item["id"], "quantity": 2}],
        },
    )
    assert create_order_response.status_code == 201

    list_orders_response = client.get("/orders", headers=headers)
    assert list_orders_response.status_code == 200
    assert len(list_orders_response.json()) > 0
