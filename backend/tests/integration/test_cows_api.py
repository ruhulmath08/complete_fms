from __future__ import annotations

import io
import re
from datetime import UTC, datetime, timedelta

from fastapi.testclient import TestClient

from tests.conftest import signup_owner

TAG_RE = re.compile(r"^.+\d{6}$")


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


def _create_cow(
    client: TestClient,
    headers: dict[str, str],
    **overrides,
) -> dict:
    body = {
        "purpose": "milk",
        "gender": "female",
        "acquired_by": "born_on_farm",
        "name": "Bella",
        "breed": "Holstein",
    }
    body.update(overrides)
    response = client.post("/api/v1/cows", headers=headers, json=body)
    assert response.status_code == 201, response.text
    return response.json()


def test_cow_crud_archive_and_generated_tag(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    purchased = client.post(
        "/api/v1/cows",
        headers=headers,
        json={
            "purpose": "both",
            "gender": "female",
            "acquired_by": "purchased",
            "name": "Purchased",
            "breed": "Local",
            "purchase_date": "2024-06-01",
            "purchase_price": "25000.00",
        },
    )
    assert purchased.status_code == 201, purchased.text
    assert purchased.json()["tag_number"].startswith("PurchasedLocal")
    assert TAG_RE.match(purchased.json()["tag_number"])
    assert purchased.json()["image_url"] is None

    missing_purchase = client.post(
        "/api/v1/cows",
        headers=headers,
        json={
            "purpose": "meat",
            "gender": "male",
            "acquired_by": "purchased",
            "name": "NoBuy",
            "breed": "Local",
        },
    )
    assert missing_purchase.status_code == 422
    assert missing_purchase.json()["code"] == "PURCHASE_FIELDS_INVALID"

    missing_name = client.post(
        "/api/v1/cows",
        headers=headers,
        json={
            "purpose": "milk",
            "gender": "female",
            "acquired_by": "born_on_farm",
            "breed": "Holstein",
        },
    )
    assert missing_name.status_code == 422

    cow = _create_cow(client, headers)
    cow_id = cow["id"]
    assert cow["tag_number"].startswith("BellaHolstein")
    assert TAG_RE.match(cow["tag_number"])

    listed = client.get("/api/v1/cows", headers=headers)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 2
    assert all(not item["is_archived"] for item in listed.json()["items"])

    patched = client.patch(
        f"/api/v1/cows/{cow_id}",
        headers=headers,
        json={"name": "Bella II", "notes": "updated"},
    )
    assert patched.status_code == 200
    assert patched.json()["name"] == "Bella II"
    assert patched.json()["tag_number"] == cow["tag_number"]

    archived = client.post(f"/api/v1/cows/{cow_id}/archive", headers=headers)
    assert archived.status_code == 200
    assert archived.json()["is_archived"] is True

    active = client.get("/api/v1/cows", headers=headers)
    assert active.status_code == 200
    assert active.json()["meta"]["total"] == 1
    assert all(item["id"] != cow_id for item in active.json()["items"])

    with_archived = client.get(
        "/api/v1/cows", headers=headers, params={"include_archived": True}
    )
    assert with_archived.json()["meta"]["total"] == 2

    got = client.get(f"/api/v1/cows/{cow_id}", headers=headers)
    assert got.status_code == 200
    assert got.json()["is_archived"] is True

    blocked = client.patch(
        f"/api/v1/cows/{cow_id}",
        headers=headers,
        json={"name": "Nope"},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "COW_ARCHIVED"

    reused = _create_cow(client, headers, name="New", breed="Tag")
    assert TAG_RE.match(reused["tag_number"])
    assert reused["id"] != cow_id


def test_cow_image_upload_get_and_delete(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    cow = _create_cow(client, headers)
    cow_id = cow["id"]

    filename, buf, content_type = sample_image
    buf.seek(0)
    uploaded = client.put(
        f"/api/v1/cows/{cow_id}/image",
        headers=headers,
        files={"image": (filename, buf, content_type)},
    )
    assert uploaded.status_code == 200, uploaded.text
    assert uploaded.json()["image_url"] == f"/api/v1/cows/{cow_id}/image"

    image = client.get(f"/api/v1/cows/{cow_id}/image", headers=headers)
    assert image.status_code == 200
    assert image.content

    cleared = client.delete(f"/api/v1/cows/{cow_id}/image", headers=headers)
    assert cleared.status_code == 200
    assert cleared.json()["image_url"] is None

    missing = client.get(f"/api/v1/cows/{cow_id}/image", headers=headers)
    assert missing.status_code == 404
    assert missing.json()["code"] == "COW_IMAGE_NOT_FOUND"


def test_milk_and_feeding_rules_and_pagination(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    milk_cow = _create_cow(client, headers, name="Milk", breed="Cow", purpose="milk")
    meat_cow = _create_cow(
        client, headers, name="Meat", breed="Cow", purpose="meat", gender="male"
    )

    produced_at = datetime(2024, 7, 1, 6, 0, tzinfo=UTC)
    for i in range(12):
        milk = client.post(
            f"/api/v1/cows/{milk_cow['id']}/milk-productions",
            headers=headers,
            json={
                "produced_at": (produced_at + timedelta(hours=i)).isoformat(),
                "quantity": "12.5",
                "unit": "L",
                "price_per_unit": "50.00",
                "note": f"entry-{i}",
            },
        )
        assert milk.status_code == 201, milk.text

    milk_list = client.get(
        f"/api/v1/cows/{milk_cow['id']}/milk-productions", headers=headers
    )
    assert milk_list.status_code == 200
    body = milk_list.json()
    assert body["meta"]["total"] == 12
    assert body["meta"]["limit"] == 10
    assert len(body["items"]) == 10

    page2 = client.get(
        f"/api/v1/cows/{milk_cow['id']}/milk-productions",
        headers=headers,
        params={"limit": 10, "offset": 10},
    )
    assert page2.status_code == 200
    assert len(page2.json()["items"]) == 2

    meat_milk = client.post(
        f"/api/v1/cows/{meat_cow['id']}/milk-productions",
        headers=headers,
        json={
            "produced_at": produced_at.isoformat(),
            "quantity": "1",
            "unit": "L",
            "price_per_unit": "0",
        },
    )
    assert meat_milk.status_code == 422
    assert meat_milk.json()["code"] == "MILK_NOT_ALLOWED_FOR_PURPOSE"

    fed_at = datetime(2024, 7, 1, 8, 0, tzinfo=UTC)
    for i in range(11):
        feeding = client.post(
            f"/api/v1/cows/{meat_cow['id']}/feedings",
            headers=headers,
            json={
                "fed_at": (fed_at + timedelta(hours=i)).isoformat(),
                "feed_name": "Hay",
                "quantity": "5",
                "unit": "kg",
            },
        )
        assert feeding.status_code == 201, feeding.text

    feed_list = client.get(
        f"/api/v1/cows/{meat_cow['id']}/feedings", headers=headers
    )
    assert feed_list.status_code == 200
    feed_body = feed_list.json()
    assert feed_body["meta"]["total"] == 11
    assert feed_body["meta"]["limit"] == 10
    assert len(feed_body["items"]) == 10

    archived = client.post(
        f"/api/v1/cows/{milk_cow['id']}/archive", headers=headers
    )
    assert archived.status_code == 200
    blocked_milk = client.post(
        f"/api/v1/cows/{milk_cow['id']}/milk-productions",
        headers=headers,
        json={
            "produced_at": produced_at.isoformat(),
            "quantity": "1",
            "unit": "L",
            "price_per_unit": "1",
        },
    )
    assert blocked_milk.status_code == 409
    assert blocked_milk.json()["code"] == "COW_ARCHIVED"
