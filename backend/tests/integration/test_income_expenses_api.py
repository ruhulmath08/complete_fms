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


def _create_entry(
    client: TestClient,
    headers: dict[str, str],
    *,
    entry_type: str = "income",
    occurred_at: str = "2024-06-15",
    category: str = "product_sale",
    amount: str = "100.00",
) -> dict:
    response = client.post(
        "/api/v1/ledger-entries",
        headers=headers,
        json={
            "entry_type": entry_type,
            "occurred_at": occurred_at,
            "category": category,
            "amount": amount,
            "unit": "pcs",
            "note": "test",
        },
    )
    assert response.status_code == 201, response.text
    return response.json()


def test_ledger_entry_crud_archive_and_total_price(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    entry = _create_entry(client, headers)
    entry_id = entry["id"]
    assert entry["amount"] == "100.00"
    assert entry["total_price"] == "100.00"
    assert entry["entry_type"] == "income"

    listed = client.get("/api/v1/ledger-entries", headers=headers)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 1

    updated = client.patch(
        f"/api/v1/ledger-entries/{entry_id}",
        headers=headers,
        json={"amount": "120.50", "category": "subsidy"},
    )
    assert updated.status_code == 200
    assert updated.json()["amount"] == "120.50"
    assert updated.json()["total_price"] == "120.50"
    assert updated.json()["category"] == "subsidy"

    archived = client.post(
        f"/api/v1/ledger-entries/{entry_id}/archive", headers=headers
    )
    assert archived.status_code == 200
    assert archived.json()["is_archived"] is True

    blocked = client.patch(
        f"/api/v1/ledger-entries/{entry_id}",
        headers=headers,
        json={"note": "nope"},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "LEDGER_ENTRY_ARCHIVED"


def test_period_totals_and_date_filters(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    _create_entry(
        client,
        headers,
        entry_type="income",
        occurred_at="2024-06-10",
        amount="200.00",
    )
    _create_entry(
        client,
        headers,
        entry_type="expense",
        occurred_at="2024-06-20",
        category="utilities",
        amount="50.00",
    )
    outside = _create_entry(
        client,
        headers,
        entry_type="income",
        occurred_at="2024-07-01",
        amount="999.00",
    )
    archived = _create_entry(
        client,
        headers,
        entry_type="expense",
        occurred_at="2024-06-15",
        category="labour",
        amount="30.00",
    )
    client.post(
        f"/api/v1/ledger-entries/{archived['id']}/archive", headers=headers
    )

    totals = client.get(
        "/api/v1/ledger-entries/totals",
        headers=headers,
        params={"from": "2024-06-01", "to": "2024-06-30"},
    )
    assert totals.status_code == 200, totals.text
    body = totals.json()
    assert body["from"] == "2024-06-01"
    assert body["to"] == "2024-06-30"
    assert body["total_income"] == "200.00"
    assert body["total_expenses"] == "50.00"
    assert body["net"] == "150.00"

    filtered = client.get(
        "/api/v1/ledger-entries",
        headers=headers,
        params={"from": "2024-06-01", "to": "2024-06-30"},
    )
    assert filtered.status_code == 200
    ids = {item["id"] for item in filtered.json()["items"]}
    assert outside["id"] not in ids
    assert archived["id"] not in ids
    assert filtered.json()["meta"]["total"] == 2

    bad = client.get(
        "/api/v1/ledger-entries/totals",
        headers=headers,
        params={"from": "2024-07-01", "to": "2024-06-01"},
    )
    assert bad.status_code == 422
