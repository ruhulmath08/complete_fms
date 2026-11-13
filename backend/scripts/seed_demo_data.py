#!/usr/bin/env python3
"""Seed rich demo farm data for local testing and presentations.

Usage (from backend/ with venv active):

    python scripts/seed_demo_data.py
    python scripts/seed_demo_data.py --reset   # wipe demo owner then reseed

Sign in as:
    email:    demo@completefms.local
    password: Password1
"""

from __future__ import annotations

import argparse
import random
import sys
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from pathlib import Path

from sqlalchemy import delete, select

BACKEND_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_ROOT))

from app.core.config import get_settings  # noqa: E402
from app.core.security import hash_password  # noqa: E402
from app.db.session import SessionLocal  # noqa: E402
from app.modules.auth.infrastructure.models import (  # noqa: E402
    FarmSettingsModel,
    OwnerModel,
)
from app.modules.cows.infrastructure.models import (  # noqa: E402
    CowFeedingModel,
    CowModel,
    MilkProductionModel,
)
from app.modules.crops.infrastructure.models import (  # noqa: E402
    CropCycleModel,
    CropExpenseModel,
    CropNameModel,
    HarvestModel,
)
from app.modules.income_expenses.infrastructure.models import (  # noqa: E402
    LedgerEntryModel,
)
from app.modules.inventory.infrastructure.models import (  # noqa: E402
    InventoryItemModel,
    StockUpdateModel,
)
from app.modules.poultry.infrastructure.models import (  # noqa: E402
    EggProductionModel,
    PoultryFeedingModel,
    PoultryGroupModel,
)

DEMO_EMAIL = "demo@completefms.local"
DEMO_PHONE = "+8801710000001"
DEMO_PASSWORD = "Password1"

# Tiny 1x1 PNG
_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01"
    b"\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde"
    b"\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N"
    b"\x00\x00\x00\x00IEND\xaeB`\x82"
)


def _dec(value: float | str) -> Decimal:
    return Decimal(str(value))


def _at(day: date, hour: int = 8, minute: int = 0) -> datetime:
    return datetime(day.year, day.month, day.day, hour, minute, tzinfo=UTC)


def _ensure_profile_image(owner_id) -> str:
    settings = get_settings()
    folder = settings.profile_images_path / str(owner_id)
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / "demo.png"
    if not path.exists():
        path.write_bytes(_PNG)
    return f"profile_images/{owner_id}/demo.png"


def _wipe_demo_owner(session) -> None:
    """Delete demo owner via SQL so DB ON DELETE CASCADE runs.

    ORM ``session.delete(owner)`` nulls ``farm_settings.owner_id`` first and
    trips the NOT NULL constraint.
    """
    owner = session.scalar(select(OwnerModel).where(OwnerModel.email == DEMO_EMAIL))
    if owner is None:
        # Clean leftover rows from a previous failed wipe
        session.execute(
            delete(FarmSettingsModel).where(FarmSettingsModel.owner_id.is_(None))
        )
        session.commit()
        return

    owner_id = owner.id
    # Drop dependent settings first (avoids ORM nulling the FK)
    session.execute(
        delete(FarmSettingsModel).where(FarmSettingsModel.owner_id == owner_id)
    )
    session.execute(delete(OwnerModel).where(OwnerModel.id == owner_id))
    session.commit()
    print(f"Removed existing demo owner {DEMO_EMAIL}")


def _get_or_create_owner(session) -> OwnerModel:
    owner = session.scalar(select(OwnerModel).where(OwnerModel.email == DEMO_EMAIL))
    if owner is not None:
        return owner

    owner = OwnerModel(
        full_name="Demo Farm Owner",
        email=DEMO_EMAIL,
        phone=DEMO_PHONE,
        address="42 Green Valley Road, Gazipur, Bangladesh",
        latitude=23.9999,
        longitude=90.4203,
        profile_image_path="pending",
        password_hash=hash_password(DEMO_PASSWORD),
    )
    session.add(owner)
    session.flush()
    owner.profile_image_path = _ensure_profile_image(owner.id)
    session.add(
        FarmSettingsModel(
            owner_id=owner.id,
            currency_code="BDT",
            timezone="Asia/Dhaka",
        )
    )
    session.flush()
    print(f"Created demo owner {DEMO_EMAIL}")
    return owner


def _seed_cows(session, owner_id, today: date, rng: random.Random) -> list[CowModel]:
    cows_spec = [
        ("CW-101", "Rani", "Sahiwal", "milk", "female"),
        ("CW-102", "Moti", "Local", "both", "female"),
        ("CW-103", "Bahadur", "Friesian cross", "meat", "male"),
    ]
    cows: list[CowModel] = []
    for tag, name, breed, purpose, gender in cows_spec:
        cow = CowModel(
            owner_id=owner_id,
            tag_number=tag,
            name=name,
            breed=breed,
            date_of_birth=today - timedelta(days=rng.randint(400, 1400)),
            purpose=purpose,
            gender=gender,
            color=rng.choice(["brown", "black", "white-brown"]),
            weight=_dec(rng.randint(280, 520)),
            age=rng.randint(2, 7),
            acquired_by="purchased",
            purchase_date=today - timedelta(days=rng.randint(60, 400)),
            purchase_price=_dec(rng.randint(45000, 120000)),
            notes=f"Demo cow {name}",
            is_archived=False,
        )
        session.add(cow)
        cows.append(cow)
    session.flush()

    milk_cows = [c for c in cows if c.purpose in ("milk", "both")]
    for day_offset in range(13, -1, -1):
        day = today - timedelta(days=day_offset)
        for cow in milk_cows:
            qty = _dec(round(rng.uniform(8.5, 14.5), 1))
            session.add(
                MilkProductionModel(
                    cow_id=cow.id,
                    owner_id=owner_id,
                    produced_at=_at(day, hour=6, minute=rng.randint(0, 40)),
                    quantity=qty,
                    unit="L",
                    price_per_unit=_dec("65.00"),
                    note="Morning milking",
                )
            )
            session.add(
                MilkProductionModel(
                    cow_id=cow.id,
                    owner_id=owner_id,
                    produced_at=_at(day, hour=17, minute=rng.randint(0, 40)),
                    quantity=_dec(round(float(qty) * 0.85, 1)),
                    unit="L",
                    price_per_unit=_dec("65.00"),
                    note="Evening milking",
                )
            )
        for cow in cows:
            session.add(
                CowFeedingModel(
                    cow_id=cow.id,
                    owner_id=owner_id,
                    fed_at=_at(day, hour=7),
                    feed_name=rng.choice(["Green grass", "Concentrate", "Straw mix"]),
                    quantity=_dec(round(rng.uniform(4.0, 8.0), 1)),
                    unit="kg",
                    unit_cost=_dec("28.00"),
                    note=None,
                )
            )
    return cows


def _seed_poultry(session, owner_id, today: date, rng: random.Random) -> list:
    groups = [
        PoultryGroupModel(
            owner_id=owner_id,
            poultry_type="layer",
            name="Layer Shed A",
            bird_count=120,
            date_acquired=today - timedelta(days=90),
            acquired_by="purchased",
            purchase_date=today - timedelta(days=90),
            purchase_price=_dec("36000.00"),
            notes="Primary egg flock",
            is_archived=False,
        ),
        PoultryGroupModel(
            owner_id=owner_id,
            poultry_type="broiler",
            name="Broiler Batch 7",
            bird_count=80,
            date_acquired=today - timedelta(days=25),
            acquired_by="purchased",
            purchase_date=today - timedelta(days=25),
            purchase_price=_dec("24000.00"),
            notes="Meat birds",
            is_archived=False,
        ),
    ]
    for group in groups:
        session.add(group)
    session.flush()

    layers = groups[0]
    for day_offset in range(13, -1, -1):
        day = today - timedelta(days=day_offset)
        session.add(
            EggProductionModel(
                poultry_group_id=layers.id,
                owner_id=owner_id,
                produced_at=_at(day, hour=9),
                quantity=_dec(rng.randint(85, 110)),
                unit="pcs",
                price_per_unit=_dec("12.00"),
                note="Daily collection",
            )
        )
        for group in groups:
            session.add(
                PoultryFeedingModel(
                    poultry_group_id=group.id,
                    owner_id=owner_id,
                    fed_at=_at(day, hour=8),
                    feed_name="Layer mash" if group.poultry_type == "layer" else "Broiler grower",
                    quantity=_dec(round(rng.uniform(18.0, 28.0), 1)),
                    unit="kg",
                    note=None,
                )
            )
    return groups


def _seed_crops(session, owner_id, today: date, rng: random.Random) -> None:
    rice = CropNameModel(owner_id=owner_id, name="Boro Rice", notes="Demo crop", is_archived=False)
    tomato = CropNameModel(owner_id=owner_id, name="Tomato", notes="Demo crop", is_archived=False)
    session.add_all([rice, tomato])
    session.flush()

    rice_cycle = CropCycleModel(
        owner_id=owner_id,
        crop_name_id=rice.id,
        plot_name="North Field",
        area=_dec("1.50"),
        location="Block A",
        planted_at=today - timedelta(days=70),
        expected_harvest_at=today + timedelta(days=20),
        notes="Main rice plot (acres)",
        is_archived=False,
    )
    tomato_cycle = CropCycleModel(
        owner_id=owner_id,
        crop_name_id=tomato.id,
        plot_name="Kitchen Garden",
        area=_dec("0.30"),
        location="Near house",
        planted_at=today - timedelta(days=45),
        expected_harvest_at=today - timedelta(days=5),
        notes="Near end of cycle",
        is_archived=False,
    )
    session.add_all([rice_cycle, tomato_cycle])
    session.flush()

    expenses = [
        (rice_cycle, today - timedelta(days=60), "seeds", "4500.00", "Seed purchase"),
        (rice_cycle, today - timedelta(days=50), "fertilizers", "3200.00", "Urea + TSP"),
        (rice_cycle, today - timedelta(days=30), "labour", "8000.00", "Weeding"),
        (rice_cycle, today - timedelta(days=10), "irrigation", "1500.00", "Pump hire"),
        (tomato_cycle, today - timedelta(days=40), "seeds", "900.00", "Seedlings"),
        (tomato_cycle, today - timedelta(days=20), "pesticides_and_chemicals", "1100.00", "Spray"),
        (tomato_cycle, today - timedelta(days=8), "labour", "2500.00", "Harvest help"),
    ]
    for cycle, spent, category, amount, note in expenses:
        session.add(
            CropExpenseModel(
                crop_cycle_id=cycle.id,
                owner_id=owner_id,
                spent_at=spent,
                category=category,
                amount=_dec(amount),
                note=note,
            )
        )

    for day_offset in (12, 7, 3):
        session.add(
            HarvestModel(
                crop_cycle_id=tomato_cycle.id,
                owner_id=owner_id,
                harvested_at=today - timedelta(days=day_offset),
                quantity=_dec(round(rng.uniform(40, 75), 1)),
                unit="kg",
                sale_amount=_dec(round(rng.uniform(1800, 3200), 2)),
                note="Market sale",
            )
        )


def _seed_inventory(session, owner_id, today: date, rng: random.Random) -> None:
    items = [
        ("Cattle feed pellets", "feed", "320", "kg", "45.00"),
        ("Layer mash", "feed", "180", "kg", "42.00"),
        ("Urea", "fertilizer", "120", "kg", "30.00"),
        ("TSP", "fertilizer", "80", "kg", "38.00"),
        ("DAP", "fertilizer", "50", "kg", "55.00"),
        ("Neem oil", "pesticide", "12", "L", "450.00"),
        ("Hybrid maize seed", "seed", "25", "kg", "220.00"),
    ]
    created: list[InventoryItemModel] = []
    for name, category, qty, unit, price in items:
        item = InventoryItemModel(
            owner_id=owner_id,
            name=name,
            category=category,
            quantity=_dec(qty),
            unit=unit,
            price_per_unit=_dec(price),
            note="Demo stock",
            is_archived=False,
        )
        session.add(item)
        created.append(item)
    session.flush()

    fertilizers = [i for i in created if i.category == "fertilizer"]
    reasons = ["Field application", "Top dressing", "Restock", "Soil prep"]
    for day_offset in range(20, 0, -2):
        item = rng.choice(fertilizers)
        change = rng.choice(["add", "remove"])
        qty = _dec(round(rng.uniform(5, 25), 1))
        session.add(
            StockUpdateModel(
                inventory_item_id=item.id,
                owner_id=owner_id,
                occurred_at=today - timedelta(days=day_offset),
                change_type=change,
                quantity_change=qty,
                reason=rng.choice(reasons),
            )
        )
        # Keep item quantity roughly consistent
        if change == "add":
            item.quantity = item.quantity + qty
        else:
            item.quantity = max(_dec("0"), item.quantity - qty)


def _seed_ledger(session, owner_id, today: date, rng: random.Random) -> None:
    # Spread income/expense across last 3 weeks so dashboard week/month look good
    for day_offset in range(20, -1, -1):
        day = today - timedelta(days=day_offset)
        if day.weekday() < 5:  # weekdays: milk/egg sales
            session.add(
                LedgerEntryModel(
                    owner_id=owner_id,
                    entry_type="income",
                    occurred_at=day,
                    category="product_sale",
                    amount=_dec(round(rng.uniform(1800, 4500), 2)),
                    unit=None,
                    note="Milk + egg sales",
                    is_archived=False,
                )
            )
        if day_offset % 3 == 0:
            session.add(
                LedgerEntryModel(
                    owner_id=owner_id,
                    entry_type="expense",
                    occurred_at=day,
                    category="feed_or_supplies",
                    amount=_dec(round(rng.uniform(900, 2200), 2)),
                    unit=None,
                    note="Feed purchase",
                    is_archived=False,
                )
            )
        if day_offset % 7 == 0:
            session.add(
                LedgerEntryModel(
                    owner_id=owner_id,
                    entry_type="expense",
                    occurred_at=day,
                    category="utilities",
                    amount=_dec(round(rng.uniform(400, 900), 2)),
                    unit=None,
                    note="Electricity / pump",
                    is_archived=False,
                )
            )
        if day_offset == 5:
            session.add(
                LedgerEntryModel(
                    owner_id=owner_id,
                    entry_type="income",
                    occurred_at=day,
                    category="livestock_sale",
                    amount=_dec("18500.00"),
                    unit=None,
                    note="Sold one calf",
                    is_archived=False,
                )
            )
        if day_offset == 2:
            session.add(
                LedgerEntryModel(
                    owner_id=owner_id,
                    entry_type="expense",
                    occurred_at=day,
                    category="labour",
                    amount=_dec("3500.00"),
                    unit=None,
                    note="Day labourers",
                    is_archived=False,
                )
            )


def seed(*, reset: bool) -> None:
    rng = random.Random(42)  # reproducible “random”
    today = date.today()
    session = SessionLocal()
    try:
        if reset:
            _wipe_demo_owner(session)

        owner = _get_or_create_owner(session)
        has_cows = session.scalar(
            select(CowModel.id).where(CowModel.owner_id == owner.id).limit(1)
        )
        if has_cows is not None:
            print(
                "Demo owner already has farm data. "
                "Re-run with --reset to replace it."
            )
            print(f"Sign in: {DEMO_EMAIL} / {DEMO_PASSWORD}")
            return

        _ensure_profile_image(owner.id)
        _seed_cows(session, owner.id, today, rng)
        _seed_poultry(session, owner.id, today, rng)
        _seed_crops(session, owner.id, today, rng)
        _seed_inventory(session, owner.id, today, rng)
        _seed_ledger(session, owner.id, today, rng)
        session.commit()

        print("Demo data seeded successfully.")
        print(f"  Email:    {DEMO_EMAIL}")
        print(f"  Password: {DEMO_PASSWORD}")
        print("  Includes: cows, milk, poultry, eggs, crops, fertilizer stock, ledger")
        print("  Range:    ~last 2–3 weeks (dashboard week/month friendly)")
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed demo farm data")
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete existing demo owner and reseed from scratch",
    )
    args = parser.parse_args()
    seed(reset=args.reset)


if __name__ == "__main__":
    main()
