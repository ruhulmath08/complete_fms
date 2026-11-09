from __future__ import annotations

import io

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def test_private_routes_require_auth(client: TestClient) -> None:
    for path in ("/api/v1/me", "/api/v1/farm-settings", "/api/v1/me/profile-image"):
        response = client.get(path)
        assert response.status_code == 401, path
        body = response.json()
        assert body["code"] == "UNAUTHORIZED"
        assert "message" in body


def test_invalid_credentials_do_not_leak(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    assert signup_owner(client, sample_image).status_code == 201
    missing = client.post(
        "/api/v1/auth/signin",
        json={"email": "missing@example.com", "password": "Password1"},
    )
    wrong = client.post(
        "/api/v1/auth/signin",
        json={"email": "owner@example.com", "password": "WrongPass1"},
    )
    assert missing.status_code == 401
    assert wrong.status_code == 401
    assert missing.json()["code"] == "INVALID_CREDENTIALS"
    assert wrong.json()["code"] == "INVALID_CREDENTIALS"
    assert missing.json()["message"] == wrong.json()["message"]


def test_access_token_rejects_refresh_token(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    assert signup_owner(client, sample_image).status_code == 201
    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": "owner@example.com", "password": "Password1"},
    ).json()
    response = client.get(
        "/api/v1/me",
        headers={"Authorization": f"Bearer {tokens['refresh_token']}"},
    )
    assert response.status_code == 401
    assert response.json()["code"] == "UNAUTHORIZED"
