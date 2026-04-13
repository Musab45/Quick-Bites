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
    refresh_token = login_response.json()["refresh_token"]
    headers = {"Authorization": f"Bearer {token}"}

    refresh_response = client.post(
        "/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_response.status_code == 200
    refreshed_body = refresh_response.json()
    assert refreshed_body["access_token"]
    assert refreshed_body["refresh_token"]

    restaurants_response = client.get("/restaurants")
    assert restaurants_response.status_code == 200
    restaurants = restaurants_response.json()
    assert len(restaurants) > 0
    for restaurant in restaurants:
        image_url = restaurant.get("image_url", "")
        assert image_url
        assert "picsum.photos" not in image_url
        assert "loremflickr.com" in image_url

    restaurant_id = restaurants[0]["id"]
    menu_response = client.get(f"/menu/{restaurant_id}")
    assert menu_response.status_code == 200
    grouped_menu = menu_response.json()

    for items in grouped_menu.values():
        for menu_item in items:
            image_url = menu_item.get("image_url", "")
            assert image_url
            assert "picsum.photos" not in image_url
            assert "loremflickr.com" in image_url

    first_category = next(iter(grouped_menu.keys()))
    first_item = grouped_menu[first_category][0]

    create_card_response = client.post(
        "/payment-cards",
        headers=headers,
        json={
            "card_number": "4111 1111 1111 8842",
            "expiry_month": 12,
            "expiry_year": 2031,
            "cvv": "123",
            "cardholder_name": "Flow User",
            "set_as_default": True,
        },
    )
    assert create_card_response.status_code == 201
    card = create_card_response.json()
    assert card["brand"] == "Visa"
    assert card["last4"] == "8842"
    assert card["is_default"] is True

    list_cards_response = client.get("/payment-cards", headers=headers)
    assert list_cards_response.status_code == 200
    cards = list_cards_response.json()
    assert len(cards) >= 1
    assert any(item["id"] == card["id"] for item in cards)

    create_order_response = client.post(
        "/orders",
        headers=headers,
        json={
            "restaurant_id": restaurant_id,
            "address": "123 Test Street",
            "payment_method": "card",
            "saved_card_id": card["id"],
            "items": [{"menu_item_id": first_item["id"], "quantity": 2}],
        },
    )
    assert create_order_response.status_code == 201

    wallet_response = client.get("/wallet", headers=headers)
    assert wallet_response.status_code == 200
    initial_wallet = wallet_response.json()
    assert "balance" in initial_wallet

    top_up_response = client.post(
        "/wallet/top-up",
        headers=headers,
        json={"amount": 75},
    )
    assert top_up_response.status_code == 200
    topped_up_wallet = top_up_response.json()

    wallet_order_response = client.post(
        "/orders",
        headers=headers,
        json={
            "restaurant_id": restaurant_id,
            "address": "123 Test Street",
            "payment_method": "wallet",
            "items": [{"menu_item_id": first_item["id"], "quantity": 1}],
        },
    )
    assert wallet_order_response.status_code == 201
    wallet_order = wallet_order_response.json()

    post_wallet_response = client.get("/wallet", headers=headers)
    assert post_wallet_response.status_code == 200
    wallet_after_order = post_wallet_response.json()
    expected_balance = round(
        float(topped_up_wallet["balance"]) - float(wallet_order["total_amount"]),
        2,
    )
    assert abs(float(wallet_after_order["balance"]) - expected_balance) < 0.001

    list_orders_response = client.get("/orders", headers=headers)
    assert list_orders_response.status_code == 200
    assert len(list_orders_response.json()) > 0
