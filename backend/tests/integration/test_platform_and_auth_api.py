from __future__ import annotations

import io

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def test_health(client: TestClient) -> None:
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_suggested_units(client: TestClient) -> None:
    response = client.get("/api/v1/config/suggested-units")
    assert response.status_code == 200
    assert "kg" in response.json()["items"]


def test_signup_signin_profile_and_settings(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    signup = signup_owner(client, sample_image)
    assert signup.status_code == 201, signup.text
    body = signup.json()
    assert body["email"] == "owner@example.com"
    assert "password" not in body
    assert body["profile_image_url"] == "/api/v1/me/profile-image"

    dup_email = signup_owner(client, sample_image, phone="+8801722222222")
    assert dup_email.status_code == 409
    assert dup_email.json()["code"] == "EMAIL_ALREADY_EXISTS"

    dup_phone = signup_owner(
        client, sample_image, email="other@example.com", phone="+8801711111111"
    )
    assert dup_phone.status_code == 409
    assert dup_phone.json()["code"] == "PHONE_ALREADY_EXISTS"

    weak = signup_owner(
        client,
        sample_image,
        email="weak@example.com",
        phone="+8801733333333",
        password="short",
        confirm_password="short",
    )
    assert weak.status_code == 422
    assert weak.json()["code"] == "PASSWORD_INVALID"

    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": "owner@example.com", "password": "Password1"},
    )
    assert tokens.status_code == 200
    token_body = tokens.json()
    assert token_body["token_type"] == "bearer"
    assert token_body["expires_in"] == 900
    access = token_body["access_token"]
    refresh = token_body["refresh_token"]

    me = client.get("/api/v1/me", headers={"Authorization": f"Bearer {access}"})
    assert me.status_code == 200
    assert me.json()["full_name"] == "Farm Owner"

    image = client.get(
        "/api/v1/me/profile-image", headers={"Authorization": f"Bearer {access}"}
    )
    assert image.status_code == 200

    settings = client.get(
        "/api/v1/farm-settings", headers={"Authorization": f"Bearer {access}"}
    )
    assert settings.status_code == 200
    assert settings.json()["currency_code"] == "BDT"

    updated = client.patch(
        "/api/v1/farm-settings",
        headers={"Authorization": f"Bearer {access}"},
        json={"currency_code": "USD"},
    )
    assert updated.status_code == 200
    assert updated.json()["currency_code"] == "USD"

    rotated = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert rotated.status_code == 200
    new_refresh = rotated.json()["refresh_token"]
    assert new_refresh != refresh

    reuse = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert reuse.status_code == 401
    assert reuse.json()["code"] == "REFRESH_TOKEN_REUSE"

    access2 = rotated.json()["access_token"]
    signout = client.post(
        "/api/v1/auth/signout",
        headers={"Authorization": f"Bearer {access2}"},
        json={"refresh_token": new_refresh},
    )
    assert signout.status_code == 204

    after = client.post("/api/v1/auth/refresh", json={"refresh_token": new_refresh})
    assert after.status_code == 401


def test_profile_update_duplicate_phone(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    assert signup_owner(client, sample_image).status_code == 201
    assert (
        signup_owner(
            client,
            sample_image,
            email="second@example.com",
            phone="+8801799999999",
        ).status_code
        == 201
    )

    tokens = client.post(
        "/api/v1/auth/signin",
        json={"email": "owner@example.com", "password": "Password1"},
    ).json()
    response = client.patch(
        "/api/v1/me",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
        data={"phone": "+8801799999999"},
    )
    assert response.status_code == 409
    assert response.json()["code"] == "PHONE_ALREADY_EXISTS"
