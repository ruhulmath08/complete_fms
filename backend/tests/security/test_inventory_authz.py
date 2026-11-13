from __future__ import annotations

import io
import uuid

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def _token(
    client: TestClient,
    sample_image: tuple[str, io.BytesIO, str],
    *,
    email: str,
    phone: str,
) -> str:
    assert (
        signup_owner(client, sample_image, email=email, phone=phone).status_code == 201
    )
    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": email, "password": "Password1"},
    )
    assert tokens.status_code == 200
    return tokens.json()["access_token"]


def test_inventory_requires_auth(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    item_id = uuid.uuid4()
    cases = [
        ("GET", "/api/v1/inventory-items"),
        ("POST", "/api/v1/inventory-items"),
        ("GET", f"/api/v1/inventory-items/{item_id}"),
        ("PATCH", f"/api/v1/inventory-items/{item_id}"),
        ("POST", f"/api/v1/inventory-items/{item_id}/archive"),
        ("GET", f"/api/v1/inventory-items/{item_id}/stock-updates"),
        ("POST", f"/api/v1/inventory-items/{item_id}/stock-updates"),
        ("GET", "/api/v1/inventory-stock-updates"),
    ]
    for method, path in cases:
        response = client.request(method, path)
        assert response.status_code == 401, path
        assert response.json()["code"] == "UNAUTHORIZED"


def test_inventory_owner_isolation(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    token_a = _token(
        client, sample_image, email="a@example.com", phone="+8801711111111"
    )
    token_b = _token(
        client, sample_image, email="b@example.com", phone="+8801711111112"
    )
    headers_a = {"Authorization": f"Bearer {token_a}"}
    headers_b = {"Authorization": f"Bearer {token_b}"}

    created = client.post(
        "/api/v1/inventory-items",
        headers=headers_a,
        json={
            "name": "Urea",
            "category": "fertilizer",
            "quantity": "20",
            "unit": "kg",
            "price_per_unit": "30",
        },
    )
    assert created.status_code == 201
    item_id = created.json()["id"]

    cases = [
        ("GET", f"/api/v1/inventory-items/{item_id}", "INVENTORY_ITEM_NOT_FOUND"),
        ("PATCH", f"/api/v1/inventory-items/{item_id}", "INVENTORY_ITEM_NOT_FOUND"),
        ("POST", f"/api/v1/inventory-items/{item_id}/archive", "INVENTORY_ITEM_NOT_FOUND"),
        (
            "GET",
            f"/api/v1/inventory-items/{item_id}/stock-updates",
            "INVENTORY_ITEM_NOT_FOUND",
        ),
        (
            "POST",
            f"/api/v1/inventory-items/{item_id}/stock-updates",
            "INVENTORY_ITEM_NOT_FOUND",
        ),
    ]
    for method, path, code in cases:
        kwargs = {}
        if method == "PATCH":
            kwargs["json"] = {"note": "x"}
        if method == "POST" and path.endswith("/stock-updates"):
            kwargs["json"] = {
                "occurred_at": "2024-01-01",
                "change_type": "add",
                "quantity_change": "1",
            }
        response = client.request(method, path, headers=headers_b, **kwargs)
        assert response.status_code == 404, path
        assert response.json()["code"] == code

    listed = client.get("/api/v1/inventory-items", headers=headers_b)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 0
