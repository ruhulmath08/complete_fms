from __future__ import annotations

import io

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def _auth_headers(
    client: TestClient,
    sample_image: tuple[str, io.BytesIO, str],
    *,
    email: str = "owner@example.com",
    phone: str = "+8801711111111",
) -> dict[str, str]:
    assert (
        signup_owner(client, sample_image, email=email, phone=phone).status_code == 201
    )
    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": email, "password": "Password1"},
    )
    assert tokens.status_code == 200
    return {"Authorization": f"Bearer {tokens.json()['access_token']}"}


def _create_item(
    client: TestClient,
    headers: dict[str, str],
    *,
    name: str = "Layer feed",
    quantity: str = "100",
) -> dict:
    response = client.post(
        "/api/v1/inventory-items",
        headers=headers,
        json={
            "name": name,
            "category": "feed",
            "quantity": quantity,
            "unit": "kg",
            "price_per_unit": "50.00",
            "note": "starter",
        },
    )
    assert response.status_code == 201, response.text
    return response.json()


def test_inventory_item_crud_archive_and_total_price(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    item = _create_item(client, headers)
    item_id = item["id"]
    assert item["quantity"] == "100.000"
    assert item["total_price"] == "5000.00"

    listed = client.get("/api/v1/inventory-items", headers=headers)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 1

    updated = client.patch(
        f"/api/v1/inventory-items/{item_id}",
        headers=headers,
        json={"price_per_unit": "40.00", "name": "Layer feed bag"},
    )
    assert updated.status_code == 200
    assert updated.json()["name"] == "Layer feed bag"
    assert updated.json()["price_per_unit"] == "40.00"
    assert updated.json()["total_price"] == "4000.00"
    assert updated.json()["quantity"] == "100.000"

    archived = client.post(
        f"/api/v1/inventory-items/{item_id}/archive", headers=headers
    )
    assert archived.status_code == 200
    assert archived.json()["is_archived"] is True

    blocked = client.patch(
        f"/api/v1/inventory-items/{item_id}",
        headers=headers,
        json={"note": "nope"},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "INVENTORY_ITEM_ARCHIVED"

    stock_blocked = client.post(
        f"/api/v1/inventory-items/{item_id}/stock-updates",
        headers=headers,
        json={
            "occurred_at": "2024-06-01",
            "change_type": "add",
            "quantity_change": "1",
        },
    )
    assert stock_blocked.status_code == 409
    assert stock_blocked.json()["code"] == "INVENTORY_ITEM_ARCHIVED"


def test_stock_updates_adjust_quantity_and_reject_negative(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    item = _create_item(client, headers, quantity="10")
    item_id = item["id"]

    added = client.post(
        f"/api/v1/inventory-items/{item_id}/stock-updates",
        headers=headers,
        json={
            "occurred_at": "2024-06-01",
            "change_type": "add",
            "quantity_change": "5",
            "reason": "delivery",
        },
    )
    assert added.status_code == 201, added.text

    after_add = client.get(f"/api/v1/inventory-items/{item_id}", headers=headers)
    assert after_add.status_code == 200
    assert after_add.json()["quantity"] == "15.000"

    used = client.post(
        f"/api/v1/inventory-items/{item_id}/stock-updates",
        headers=headers,
        json={
            "occurred_at": "2024-06-02",
            "change_type": "use",
            "quantity_change": "4",
        },
    )
    assert used.status_code == 201, used.text

    after_use = client.get(f"/api/v1/inventory-items/{item_id}", headers=headers)
    assert after_use.status_code == 200
    assert after_use.json()["quantity"] == "11.000"

    insufficient = client.post(
        f"/api/v1/inventory-items/{item_id}/stock-updates",
        headers=headers,
        json={
            "occurred_at": "2024-06-03",
            "change_type": "use",
            "quantity_change": "12",
        },
    )
    assert insufficient.status_code == 409
    assert insufficient.json()["code"] == "INSUFFICIENT_STOCK"
    assert insufficient.json()["details"]["quantity"] == "11.000"

    listed = client.get(
        f"/api/v1/inventory-items/{item_id}/stock-updates", headers=headers
    )
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 2
