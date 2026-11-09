from __future__ import annotations

import io
from datetime import UTC, datetime

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


def _create_group(
    client: TestClient,
    headers: dict[str, str],
    **overrides,
) -> dict:
    body = {
        "poultry_type": "layer",
        "name": "House A",
        "bird_count": 100,
        "acquired_by": "born_on_farm",
    }
    body.update(overrides)
    response = client.post("/api/v1/poultry-groups", headers=headers, json=body)
    assert response.status_code == 201, response.text
    return response.json()


def test_poultry_group_crud_archive_and_duplicate_names(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    purchased = client.post(
        "/api/v1/poultry-groups",
        headers=headers,
        json={
            "poultry_type": "broiler",
            "name": "Broiler Shed",
            "bird_count": 500,
            "acquired_by": "purchased",
            "purchase_date": "2024-06-01",
            "purchase_price": "15000.00",
        },
    )
    assert purchased.status_code == 201, purchased.text

    missing_purchase = client.post(
        "/api/v1/poultry-groups",
        headers=headers,
        json={
            "poultry_type": "duck",
            "name": "Ducks",
            "bird_count": 20,
            "acquired_by": "purchased",
        },
    )
    assert missing_purchase.status_code == 422
    assert missing_purchase.json()["code"] == "PURCHASE_FIELDS_INVALID"

    group = _create_group(client, headers)
    group_id = group["id"]

    same_name = _create_group(client, headers, name="House A", bird_count=50)
    assert same_name["name"] == "House A"
    assert same_name["id"] != group_id

    listed = client.get("/api/v1/poultry-groups", headers=headers)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 3
    assert all(not item["is_archived"] for item in listed.json()["items"])

    patched = client.patch(
        f"/api/v1/poultry-groups/{group_id}",
        headers=headers,
        json={"bird_count": 120, "notes": "restocked"},
    )
    assert patched.status_code == 200
    assert patched.json()["bird_count"] == 120
    assert patched.json()["notes"] == "restocked"

    archived = client.post(
        f"/api/v1/poultry-groups/{group_id}/archive", headers=headers
    )
    assert archived.status_code == 200
    assert archived.json()["is_archived"] is True

    active = client.get("/api/v1/poultry-groups", headers=headers)
    assert active.status_code == 200
    assert active.json()["meta"]["total"] == 2
    assert all(item["id"] != group_id for item in active.json()["items"])

    with_archived = client.get(
        "/api/v1/poultry-groups",
        headers=headers,
        params={"include_archived": True},
    )
    assert with_archived.json()["meta"]["total"] == 3

    got = client.get(f"/api/v1/poultry-groups/{group_id}", headers=headers)
    assert got.status_code == 200
    assert got.json()["is_archived"] is True

    blocked = client.patch(
        f"/api/v1/poultry-groups/{group_id}",
        headers=headers,
        json={"bird_count": 1},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "POULTRY_GROUP_ARCHIVED"


def test_feeding_and_egg_rules(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    layer = _create_group(client, headers, poultry_type="layer", name="Layers")
    broiler = _create_group(
        client, headers, poultry_type="broiler", name="Broilers", bird_count=200
    )

    fed_at = datetime(2024, 7, 1, 8, 0, tzinfo=UTC).isoformat()
    feeding = client.post(
        f"/api/v1/poultry-groups/{broiler['id']}/feedings",
        headers=headers,
        json={
            "fed_at": fed_at,
            "feed_name": "Starter",
            "quantity": "25",
            "unit": "kg",
        },
    )
    assert feeding.status_code == 201, feeding.text

    feed_list = client.get(
        f"/api/v1/poultry-groups/{broiler['id']}/feedings", headers=headers
    )
    assert feed_list.status_code == 200
    assert feed_list.json()["meta"]["total"] == 1

    produced_at = datetime(2024, 7, 1, 6, 0, tzinfo=UTC).isoformat()
    eggs = client.post(
        f"/api/v1/poultry-groups/{layer['id']}/egg-productions",
        headers=headers,
        json={
            "produced_at": produced_at,
            "quantity": "80",
            "unit": "pcs",
            "price_per_unit": "12.00",
            "note": "morning",
        },
    )
    assert eggs.status_code == 201, eggs.text
    assert eggs.json()["quantity"] == "80.000"

    egg_list = client.get(
        f"/api/v1/poultry-groups/{layer['id']}/egg-productions", headers=headers
    )
    assert egg_list.status_code == 200
    assert egg_list.json()["meta"]["total"] == 1

    broiler_eggs = client.post(
        f"/api/v1/poultry-groups/{broiler['id']}/egg-productions",
        headers=headers,
        json={
            "produced_at": produced_at,
            "quantity": "1",
            "unit": "pcs",
            "price_per_unit": "0",
        },
    )
    assert broiler_eggs.status_code == 422
    assert broiler_eggs.json()["code"] == "EGGS_NOT_ALLOWED_FOR_TYPE"

    archived = client.post(
        f"/api/v1/poultry-groups/{layer['id']}/archive", headers=headers
    )
    assert archived.status_code == 200
    blocked_eggs = client.post(
        f"/api/v1/poultry-groups/{layer['id']}/egg-productions",
        headers=headers,
        json={
            "produced_at": produced_at,
            "quantity": "1",
            "unit": "pcs",
            "price_per_unit": "1",
        },
    )
    assert blocked_eggs.status_code == 409
    assert blocked_eggs.json()["code"] == "POULTRY_GROUP_ARCHIVED"
