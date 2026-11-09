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


def _create_name(
    client: TestClient, headers: dict[str, str], name: str = "Rice"
) -> dict:
    response = client.post(
        "/api/v1/crop-names", headers=headers, json={"name": name}
    )
    assert response.status_code == 201, response.text
    return response.json()


def test_crop_names_and_cycles_crud_archive(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)

    name = _create_name(client, headers)
    name_id = name["id"]

    dup = client.post("/api/v1/crop-names", headers=headers, json={"name": "Rice"})
    assert dup.status_code == 409
    assert dup.json()["code"] == "CROP_NAME_ALREADY_EXISTS"

    cycle = client.post(
        "/api/v1/crop-cycles",
        headers=headers,
        json={
            "crop_name_id": name_id,
            "planted_at": "2024-06-01",
            "plot_name": "North field",
            "area": "2.5",
        },
    )
    assert cycle.status_code == 201, cycle.text
    cycle_id = cycle.json()["id"]

    listed = client.get("/api/v1/crop-cycles", headers=headers)
    assert listed.status_code == 200
    assert listed.json()["meta"]["total"] == 1

    archived_name = client.post(
        f"/api/v1/crop-names/{name_id}/archive", headers=headers
    )
    assert archived_name.status_code == 200
    assert archived_name.json()["is_archived"] is True

    reused = _create_name(client, headers, name="Rice")
    assert reused["id"] != name_id

    bad_cycle = client.post(
        "/api/v1/crop-cycles",
        headers=headers,
        json={"crop_name_id": name_id, "planted_at": "2024-07-01"},
    )
    assert bad_cycle.status_code == 422
    assert bad_cycle.json()["code"] == "CROP_NAME_ARCHIVED"

    archived_cycle = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/archive", headers=headers
    )
    assert archived_cycle.status_code == 200
    assert archived_cycle.json()["is_archived"] is True

    blocked = client.patch(
        f"/api/v1/crop-cycles/{cycle_id}",
        headers=headers,
        json={"plot_name": "Nope"},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "CROP_CYCLE_ARCHIVED"


def test_expenses_harvests_and_summary(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str]
) -> None:
    headers = _auth_headers(client, sample_image)
    name = _create_name(client, headers, name="Tomato")
    cycle = client.post(
        "/api/v1/crop-cycles",
        headers=headers,
        json={"crop_name_id": name["id"], "planted_at": "2024-03-01"},
    )
    assert cycle.status_code == 201
    cycle_id = cycle.json()["id"]

    expense = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/expenses",
        headers=headers,
        json={
            "spent_at": "2024-03-05",
            "category": "seeds",
            "amount": "100.00",
            "note": "starter",
        },
    )
    assert expense.status_code == 201, expense.text

    expense2 = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/expenses",
        headers=headers,
        json={
            "spent_at": "2024-03-10",
            "category": "labour",
            "amount": "50.50",
        },
    )
    assert expense2.status_code == 201

    harvest = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/harvests",
        headers=headers,
        json={
            "harvested_at": "2024-06-01",
            "quantity": "200",
            "unit": "kg",
            "sale_amount": "400.00",
        },
    )
    assert harvest.status_code == 201, harvest.text

    harvest_no_sale = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/harvests",
        headers=headers,
        json={
            "harvested_at": "2024-06-02",
            "quantity": "10",
            "unit": "kg",
        },
    )
    assert harvest_no_sale.status_code == 201

    summary = client.get(f"/api/v1/crop-cycles/{cycle_id}/summary", headers=headers)
    assert summary.status_code == 200
    body = summary.json()
    assert body["total_expenses"] == "150.50"
    assert body["total_sale_income"] == "400.00"
    assert body["result"] == "249.50"

    expenses = client.get(f"/api/v1/crop-cycles/{cycle_id}/expenses", headers=headers)
    assert expenses.status_code == 200
    assert expenses.json()["meta"]["total"] == 2

    harvests = client.get(f"/api/v1/crop-cycles/{cycle_id}/harvests", headers=headers)
    assert harvests.status_code == 200
    assert harvests.json()["meta"]["total"] == 2

    client.post(f"/api/v1/crop-cycles/{cycle_id}/archive", headers=headers)
    blocked = client.post(
        f"/api/v1/crop-cycles/{cycle_id}/expenses",
        headers=headers,
        json={"spent_at": "2024-07-01", "category": "other", "amount": "1"},
    )
    assert blocked.status_code == 409
    assert blocked.json()["code"] == "CROP_CYCLE_ARCHIVED"
