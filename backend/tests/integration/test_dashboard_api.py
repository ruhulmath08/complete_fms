from __future__ import annotations

import io
from datetime import date, timedelta

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def _auth_headers(
    client: TestClient,
    sample_image: tuple[str, io.BytesIO, str],
) -> dict[str, str]:
    assert signup_owner(client, sample_image).status_code == 201
    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": "owner@example.com", "password": "Password1"},
    )
    assert tokens.status_code == 200
    return {"Authorization": f"Bearer {tokens.json()['access_token']}"}


def test_dashboard_aggregates_and_future_date_rejected(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    today = date.today()
    week_start = today - timedelta(days=today.weekday())

    client.post(
        "/api/v1/ledger-entries",
        headers=headers,
        json={
            "entry_type": "income",
            "occurred_at": week_start.isoformat(),
            "category": "product_sale",
            "amount": "100.00",
        },
    )
    client.post(
        "/api/v1/ledger-entries",
        headers=headers,
        json={
            "entry_type": "expense",
            "occurred_at": week_start.isoformat(),
            "category": "utilities",
            "amount": "40.00",
        },
    )

    ok = client.get(
        "/api/v1/dashboard/aggregates",
        headers=headers,
        params={
            "from": week_start.isoformat(),
            "to": today.isoformat(),
            "grain": "week",
        },
    )
    assert ok.status_code == 200, ok.text
    body = ok.json()
    assert body["grain"] == "week"
    assert body["timezone"] == "Asia/Dhaka"
    assert "egg_production" in body["series"]
    assert "hen_headcount" in body["series"]
    assert "milk" in body["series"]
    assert "cow_production" in body["series"]
    assert "expenses_cost" in body["series"]
    assert "income" in body["series"]
    assert body["series"]["income"][0]["value"] == "100.00"
    assert body["series"]["expenses_cost"][0]["value"] == "40.00"

    future = client.get(
        "/api/v1/dashboard/aggregates",
        headers=headers,
        params={
            "from": week_start.isoformat(),
            "to": (today + timedelta(days=1)).isoformat(),
            "grain": "day",
        },
    )
    assert future.status_code == 422
    assert future.json()["code"] == "FUTURE_DATE_NOT_ALLOWED"


def test_ledger_series_zero_filled(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    today = date.today()
    start = today - timedelta(days=2)

    client.post(
        "/api/v1/ledger-entries",
        headers=headers,
        json={
            "entry_type": "income",
            "occurred_at": start.isoformat(),
            "category": "product_sale",
            "amount": "25.00",
        },
    )

    series = client.get(
        "/api/v1/ledger-entries/series",
        headers=headers,
        params={"from": start.isoformat(), "to": today.isoformat(), "grain": "day"},
    )
    assert series.status_code == 200, series.text
    body = series.json()
    assert body["grain"] == "day"
    assert len(body["points"]) == 3
    assert body["points"][0]["income"] == "25.00"
    assert body["points"][1]["income"] == "0.00"
