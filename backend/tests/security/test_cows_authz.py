from __future__ import annotations

import io
from uuid import uuid4

from fastapi.testclient import TestClient

from tests.conftest import signup_owner


def _signin(
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


def test_cows_routes_require_auth(client: TestClient) -> None:
    cow_id = uuid4()
    paths = [
        ("GET", "/api/v1/cows"),
        ("POST", "/api/v1/cows"),
        ("GET", f"/api/v1/cows/{cow_id}"),
        ("PATCH", f"/api/v1/cows/{cow_id}"),
        ("POST", f"/api/v1/cows/{cow_id}/archive"),
        ("GET", f"/api/v1/cows/{cow_id}/milk-productions"),
        ("POST", f"/api/v1/cows/{cow_id}/milk-productions"),
        ("GET", f"/api/v1/cows/{cow_id}/feedings"),
        ("POST", f"/api/v1/cows/{cow_id}/feedings"),
    ]
    for method, path in paths:
        response = client.request(method, path, json={})
        assert response.status_code == 401, path
        assert response.json()["code"] == "UNAUTHORIZED"


def test_other_owner_cow_is_not_found(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    access_a = _signin(
        client, sample_image, email="a@example.com", phone="+8801711111111"
    )
    create = client.post(
        "/api/v1/cows",
        headers={"Authorization": f"Bearer {access_a}"},
        json={
            "tag_number": "A-1",
            "purpose": "milk",
            "gender": "female",
            "acquired_by": "born_on_farm",
        },
    )
    assert create.status_code == 201
    cow_id = create.json()["id"]

    access_b = _signin(
        client, sample_image, email="b@example.com", phone="+8801722222222"
    )
    headers_b = {"Authorization": f"Bearer {access_b}"}

    for method, path in (
        ("GET", f"/api/v1/cows/{cow_id}"),
        ("PATCH", f"/api/v1/cows/{cow_id}"),
        ("POST", f"/api/v1/cows/{cow_id}/archive"),
        ("GET", f"/api/v1/cows/{cow_id}/milk-productions"),
        ("GET", f"/api/v1/cows/{cow_id}/feedings"),
    ):
        kwargs = {"headers": headers_b}
        if method == "PATCH":
            kwargs["json"] = {"name": "stolen"}
        response = client.request(method, path, **kwargs)
        assert response.status_code == 404, path
        assert response.json()["code"] == "COW_NOT_FOUND"

    listed = client.get("/api/v1/cows", headers=headers_b)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 0
    assert listed.json()["items"] == []
