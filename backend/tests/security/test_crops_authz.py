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


def test_crops_routes_require_auth(client: TestClient) -> None:
    name_id = uuid4()
    cycle_id = uuid4()
    paths = [
        ("GET", "/api/v1/crop-names"),
        ("POST", "/api/v1/crop-names"),
        ("GET", f"/api/v1/crop-names/{name_id}"),
        ("PATCH", f"/api/v1/crop-names/{name_id}"),
        ("POST", f"/api/v1/crop-names/{name_id}/archive"),
        ("GET", "/api/v1/crop-cycles"),
        ("POST", "/api/v1/crop-cycles"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}"),
        ("PATCH", f"/api/v1/crop-cycles/{cycle_id}"),
        ("POST", f"/api/v1/crop-cycles/{cycle_id}/archive"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/summary"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/expenses"),
        ("POST", f"/api/v1/crop-cycles/{cycle_id}/expenses"),
        ("PATCH", f"/api/v1/crop-cycles/{cycle_id}/expenses/{uuid4()}"),
        ("DELETE", f"/api/v1/crop-cycles/{cycle_id}/expenses/{uuid4()}"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/harvests"),
        ("POST", f"/api/v1/crop-cycles/{cycle_id}/harvests"),
        ("PATCH", f"/api/v1/crop-cycles/{cycle_id}/harvests/{uuid4()}"),
        ("DELETE", f"/api/v1/crop-cycles/{cycle_id}/harvests/{uuid4()}"),
    ]
    for method, path in paths:
        response = client.request(method, path, json={})
        assert response.status_code == 401, path
        assert response.json()["code"] == "UNAUTHORIZED"


def test_other_owner_crops_are_not_found(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    access_a = _signin(
        client, sample_image, email="a@example.com", phone="+8801711111111"
    )
    headers_a = {"Authorization": f"Bearer {access_a}"}
    name = client.post(
        "/api/v1/crop-names", headers=headers_a, json={"name": "Rice"}
    )
    assert name.status_code == 201
    name_id = name.json()["id"]
    cycle = client.post(
        "/api/v1/crop-cycles",
        headers=headers_a,
        json={"crop_name_id": name_id, "planted_at": "2024-01-01"},
    )
    assert cycle.status_code == 201
    cycle_id = cycle.json()["id"]

    access_b = _signin(
        client, sample_image, email="b@example.com", phone="+8801722222222"
    )
    headers_b = {"Authorization": f"Bearer {access_b}"}

    for method, path, code in (
        ("GET", f"/api/v1/crop-names/{name_id}", "CROP_NAME_NOT_FOUND"),
        ("PATCH", f"/api/v1/crop-names/{name_id}", "CROP_NAME_NOT_FOUND"),
        ("POST", f"/api/v1/crop-names/{name_id}/archive", "CROP_NAME_NOT_FOUND"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}", "CROP_CYCLE_NOT_FOUND"),
        ("PATCH", f"/api/v1/crop-cycles/{cycle_id}", "CROP_CYCLE_NOT_FOUND"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/summary", "CROP_CYCLE_NOT_FOUND"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/expenses", "CROP_CYCLE_NOT_FOUND"),
        ("GET", f"/api/v1/crop-cycles/{cycle_id}/harvests", "CROP_CYCLE_NOT_FOUND"),
    ):
        kwargs: dict = {"headers": headers_b}
        if method == "PATCH":
            kwargs["json"] = {"notes": "x"}
        response = client.request(method, path, **kwargs)
        assert response.status_code == 404, path
        assert response.json()["code"] == code

    listed_names = client.get("/api/v1/crop-names", headers=headers_b)
    assert listed_names.json()["meta"]["total"] == 0
    listed_cycles = client.get("/api/v1/crop-cycles", headers=headers_b)
    assert listed_cycles.json()["meta"]["total"] == 0
