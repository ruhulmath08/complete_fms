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


def test_ledger_requires_auth(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    entry_id = uuid.uuid4()
    cases = [
        ("GET", "/api/v1/ledger-entries"),
        ("POST", "/api/v1/ledger-entries"),
        ("GET", "/api/v1/ledger-entries/totals?from=2024-01-01&to=2024-01-31"),
        ("GET", "/api/v1/ledger-entries/series?from=2024-01-01&to=2024-01-31&grain=day"),
        ("GET", "/api/v1/dashboard/aggregates?from=2024-01-01&to=2024-01-31&grain=week"),
        ("GET", f"/api/v1/ledger-entries/{entry_id}"),
        ("PATCH", f"/api/v1/ledger-entries/{entry_id}"),
        ("POST", f"/api/v1/ledger-entries/{entry_id}/archive"),
    ]
    for method, path in cases:
        response = client.request(method, path)
        assert response.status_code == 401, path
        assert response.json()["code"] == "UNAUTHORIZED"


def test_ledger_owner_isolation(
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
        "/api/v1/ledger-entries",
        headers=headers_a,
        json={
            "entry_type": "expense",
            "occurred_at": "2024-06-01",
            "category": "transport",
            "amount": "25.00",
        },
    )
    assert created.status_code == 201
    entry_id = created.json()["id"]

    cases = [
        ("GET", f"/api/v1/ledger-entries/{entry_id}", None),
        ("PATCH", f"/api/v1/ledger-entries/{entry_id}", {"note": "x"}),
        ("POST", f"/api/v1/ledger-entries/{entry_id}/archive", None),
    ]
    for method, path, json_body in cases:
        response = client.request(
            method, path, headers=headers_b, json=json_body
        )
        assert response.status_code == 404, path
        assert response.json()["code"] == "LEDGER_ENTRY_NOT_FOUND"
