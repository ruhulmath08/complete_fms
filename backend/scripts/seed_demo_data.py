#!/usr/bin/env python3
"""Seed a client-demo farm for the last 90 days through today.

Usage (from backend/ with venv active):

    python scripts/seed_demo_data.py
    python scripts/seed_demo_data.py --reset   # wipe demo owner then reseed

Sign in as:
    email:    demo@completefms.com
    password: Password1
"""

from __future__ import annotations

import argparse
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

# Use a normal TLD — pydantic EmailStr rejects reserved domains like .local
DEMO_EMAIL = "demo@completefms.com"
DEMO_PHONE = "+8801710000001"
DEMO_PASSWORD = "Password1"
LEGACY_DEMO_EMAILS = ("demo@completefms.local",)

# Tiny 1x1 PNG
_PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01"
    b"\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde"
    b"\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N"
    b"\x00\x00\x00\x00IEND\xaeB`\x82"
)


# Inclusive window ending today: offset 89 is the first day, offset 0 is today.
HISTORY_DAYS = 90


def _dec(value: float | str) -> Decimal:
    return Decimal(str(value))


def _history_start_offset() -> int:
    return HISTORY_DAYS - 1


def _history_start(today: date) -> date:
    return today - timedelta(days=_history_start_offset())


def _at(day: date, hour: int = 8, minute: int = 0) -> datetime:
    return datetime(day.year, day.month, day.day, hour, minute, tzinfo=UTC)


DEMO_ASSETS = Path(__file__).resolve().parent / "demo_assets"


def _ensure_profile_image(owner_id) -> str:
    settings = get_settings()
    folder = settings.profile_images_path / str(owner_id)
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / "demo.png"
    if not path.exists():
        path.write_bytes(_PNG)
    return f"profile_images/{owner_id}/demo.png"


def _ensure_cow_image(owner_id, cow_id, asset_name: str) -> str:
    """Copy a bundled demo JPEG into uploads/cow_images/{owner}/{cow}/."""
    settings = get_settings()
    src = DEMO_ASSETS / asset_name
    folder = settings.cow_images_path / str(owner_id) / str(cow_id)
    folder.mkdir(parents=True, exist_ok=True)
    dest = folder / "demo.jpg"
    if src.is_file():
        dest.write_bytes(src.read_bytes())
    else:
        # Fallback tiny PNG renamed — API accepts jpeg/png; use png bytes with .png
        dest = folder / "demo.png"
        dest.write_bytes(_PNG)
        return f"cow_images/{owner_id}/{cow_id}/demo.png"
    return f"cow_images/{owner_id}/{cow_id}/demo.jpg"


def _wipe_demo_owner(session) -> None:
    """Delete demo owner via SQL so DB ON DELETE CASCADE runs.

    ORM ``session.delete(owner)`` nulls ``farm_settings.owner_id`` first and
    trips the NOT NULL constraint.
    """
    emails = (DEMO_EMAIL, *LEGACY_DEMO_EMAILS)
    owners = session.scalars(select(OwnerModel).where(OwnerModel.email.in_(emails))).all()
    if not owners:
        session.execute(
            delete(FarmSettingsModel).where(FarmSettingsModel.owner_id.is_(None))
        )
        session.commit()
        return

    for owner in owners:
        session.execute(
            delete(FarmSettingsModel).where(FarmSettingsModel.owner_id == owner.id)
        )
        session.execute(delete(OwnerModel).where(OwnerModel.id == owner.id))
        print(f"Removed existing demo owner {owner.email}")
    session.commit()


def _money(value: float) -> Decimal:
    return _dec(f"{value:.2f}")


def _qty(value: float) -> Decimal:
    return _dec(f"{value:.1f}")


def _rani_sick(day_offset: int) -> bool:
    """Three-day dip a client can point at on the milk chart."""
    return day_offset in (14, 13, 12)


def _milk_shift(baseline: float, day_offset: int) -> float:
    """Small weekday wave so the chart moves without looking random."""
    return round(baseline + ((day_offset % 7) - 3) * 0.15, 1)


def _session_liters(baseline: float, day_offset: int, *, sick: bool) -> tuple[float, float]:
    morning = _milk_shift(baseline, day_offset)
    if sick:
        morning = round(morning * 0.55, 1)
    evening = round(morning * 0.82, 1)
    return morning, evening


# Morning baselines for the 15 dual-purpose cows. Index 0 is Rani.
_BOTH_BASELINES = (12.5, 9.2, 11.0, 10.4, 8.8, 13.1, 9.6, 10.8, 8.5, 11.6, 9.9, 12.0, 8.2, 10.2, 11.4)
LAYER_HENS = 1000


def _day_milk_liters(day_offset: int) -> float:
    total = 0.0
    for index, baseline in enumerate(_BOTH_BASELINES):
        morning, evening = _session_liters(
            baseline, day_offset, sick=_rani_sick(day_offset) and index == 0
        )
        total += morning + evening
    return round(total, 1)


def _layer_eggs(day_offset: int) -> int:
    """About a 72% lay rate for the 1,000 hens."""
    return 720 + ((day_offset % 5) - 2) * 6


def _duck_eggs(day_offset: int) -> int:
    return 16 + (day_offset % 3)


def _get_or_create_owner(session) -> OwnerModel:
    owner = session.scalar(select(OwnerModel).where(OwnerModel.email == DEMO_EMAIL))
    if owner is not None:
        return owner

    owner = OwnerModel(
        full_name="Karim Hossain",
        email=DEMO_EMAIL,
        phone=DEMO_PHONE,
        address="Green Valley Farm, Konabari, Gazipur 1700, Bangladesh",
        latitude=24.0167,
        longitude=90.3889,
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


MILK_PRICE = "75.00"
EGG_PRICE = "12.00"
BROILER_AGE_DAYS = 32

_FEEDS = (
    ("Cut green grass", 8.0, "0.00", "Cut on the farm"),
    ("Cattle concentrate", 4.5, "52.00", "From the Gazipur feed dealer"),
    ("Rice straw", 6.0, "8.00", "Stored from the last rice harvest"),
)


# name, breed, color, weight kg, age years, price, image or None, notes
_BOTH_COWS = (
    ("Rani", "Sahiwal", "red-brown", 410, 5, "95000.00", "cow_rani.jpg", "Lead milker. Twice a day. Yield dropped for three days after a vet visit."),
    ("Moti", "Local", "black and white", 360, 6, "72000.00", "cow_moti.jpg", "Steady milker and the dam of the last calf sold this season."),
    ("Lakshmi", "Sahiwal", "brown", 390, 4, "78000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Sundari", "Friesian cross", "black", 430, 5, "88000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Kali", "Local", "black", 340, 7, "64000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Kamala", "Sahiwal", "red-brown", 400, 4, "86000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Beli", "Pabna", "white", 370, 5, "70000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Parul", "Red Chittagong", "red", 355, 6, "68000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Asha", "Local", "brown", 345, 8, "60000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Durga", "Friesian cross", "black and white", 445, 4, "92000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Meghla", "Sahiwal", "grey", 385, 5, "76000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Champa", "Pabna", "white-brown", 395, 3, "80000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Nishi", "Local", "black", 330, 7, "58000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Rupa", "Red Chittagong", "red-brown", 360, 5, "69000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
    ("Fulmoni", "Sahiwal", "brown", 405, 4, "84000.00", None, "Dual-purpose cow. Milked twice a day with the dairy herd."),
)
_MEAT_COWS = (
    ("Bahadur", "Friesian cross", "grey-white", 480, 3, "110000.00", "cow_bahadur.jpg", "Fattening bull. Not milked. Fed with the dairy cows each morning."),
    ("Raja", "Local", "black", 460, 4, "98000.00", None, "Fattening bull. Not milked."),
    ("Badsha", "Friesian cross", "black and white", 510, 3, "120000.00", None, "Fattening bull. Not milked."),
    ("Kalu", "Local", "black", 440, 5, "90000.00", None, "Fattening bull. Not milked."),
    ("Sultan", "Sahiwal", "red-brown", 470, 4, "105000.00", None, "Fattening bull. Not milked."),
    ("Boxer", "Friesian cross", "grey", 500, 3, "115000.00", None, "Fattening bull. Not milked."),
    ("Bholu", "Local", "brown", 430, 6, "86000.00", None, "Fattening bull. Not milked."),
    ("Tiger", "Red Chittagong", "red", 455, 4, "94000.00", None, "Fattening bull. Not milked."),
    ("Hero", "Pabna", "white", 445, 3, "91000.00", None, "Fattening bull. Not milked."),
    ("Diamond", "Friesian cross", "black", 495, 4, "118000.00", None, "Fattening bull. Not milked."),
)


def _seed_cows(session, owner_id, today: date) -> list[CowModel]:
    started = _history_start(today)
    if len(_BOTH_COWS) != len(_BOTH_BASELINES):
        raise RuntimeError("Dual-purpose cow list and milk baselines are out of sync")
    cows_spec = []
    for index, (name, breed, color, weight, age, price, image, notes) in enumerate(_BOTH_COWS):
        cows_spec.append(
            {
                "tag": f"CW-{101 + index}",
                "name": name,
                "breed": breed,
                "purpose": "both",
                "gender": "female",
                "color": color,
                "weight": str(weight),
                "age": age,
                "price": price,
                "image": image,
                "baseline": _BOTH_BASELINES[index],
                "notes": notes,
            }
        )
    for index, (name, breed, color, weight, age, price, image, notes) in enumerate(_MEAT_COWS):
        cows_spec.append(
            {
                "tag": f"CW-{201 + index}",
                "name": name,
                "breed": breed,
                "purpose": "meat",
                "gender": "male",
                "color": color,
                "weight": str(weight),
                "age": age,
                "price": price,
                "image": image,
                "baseline": None,
                "notes": notes,
            }
        )
    cows: list[tuple[CowModel, float | None]] = []
    for spec in cows_spec:
        cow = CowModel(
            owner_id=owner_id,
            tag_number=spec["tag"],
            name=spec["name"],
            breed=spec["breed"],
            date_of_birth=today - timedelta(days=spec["age"] * 365),
            purpose=spec["purpose"],
            gender=spec["gender"],
            color=spec["color"],
            weight=_dec(spec["weight"]),
            age=spec["age"],
            acquired_by="purchased",
            purchase_date=started,
            purchase_price=_dec(spec["price"]),
            notes=spec["notes"],
            is_archived=False,
        )
        session.add(cow)
        cows.append((cow, spec["baseline"]))
    session.flush()
    for (cow, _), spec in zip(cows, cows_spec, strict=True):
        if spec["image"]:
            cow.image_path = _ensure_cow_image(owner_id, cow.id, spec["image"])

    for day_offset in range(_history_start_offset(), -1, -1):
        day = today - timedelta(days=day_offset)
        sick = _rani_sick(day_offset)
        for cow, baseline in cows:
            if baseline is not None:
                morning, evening = _session_liters(baseline, day_offset, sick=sick and cow.name == "Rani")
                morning_note = "Morning milking"
                evening_note = "Evening milking"
                if sick and cow.name == "Rani":
                    morning_note = "Morning milking — yield down after treatment"
                    evening_note = "Evening milking — still recovering"
                session.add(
                    MilkProductionModel(
                        cow_id=cow.id,
                        owner_id=owner_id,
                        produced_at=_at(day, hour=6, minute=15),
                        quantity=_qty(morning),
                        unit="L",
                        price_per_unit=_dec(MILK_PRICE),
                        note=morning_note,
                    )
                )
                session.add(
                    MilkProductionModel(
                        cow_id=cow.id,
                        owner_id=owner_id,
                        produced_at=_at(day, hour=17, minute=10),
                        quantity=_qty(evening),
                        unit="L",
                        price_per_unit=_dec(MILK_PRICE),
                        note=evening_note,
                    )
                )
            feed_name, feed_qty, unit_cost, feed_note = _FEEDS[day_offset % len(_FEEDS)]
            session.add(
                CowFeedingModel(
                    cow_id=cow.id,
                    owner_id=owner_id,
                    fed_at=_at(day, hour=7),
                    feed_name=feed_name,
                    quantity=_qty(feed_qty if cow.purpose != "meat" else feed_qty + 1.5),
                    unit="kg",
                    unit_cost=_dec(unit_cost),
                    note=feed_note,
                )
            )
    return [cow for cow, _ in cows]


def _seed_poultry(session, owner_id, today: date) -> list:
    started = _history_start(today)
    broiler_start = today - timedelta(days=BROILER_AGE_DAYS)
    layers = PoultryGroupModel(
        owner_id=owner_id,
        poultry_type="layer",
        name="Layer Shed A",
        bird_count=LAYER_HENS,
        date_acquired=started,
        acquired_by="purchased",
        purchase_date=started,
        purchase_price=_dec("280000.00"),
        notes="1,000 Sonali hens from the Joydebpur hatchery. About 72% lay rate.",
        is_archived=False,
    )
    ducks = PoultryGroupModel(
        owner_id=owner_id,
        poultry_type="duck",
        name="Pond ducks",
        bird_count=28,
        date_acquired=started,
        acquired_by="purchased",
        purchase_date=started,
        purchase_price=_dec("8400.00"),
        notes="Local ducks on the farm pond. Eggs sold with the hen eggs.",
        is_archived=False,
    )
    broilers = PoultryGroupModel(
        owner_id=owner_id,
        poultry_type="broiler",
        name="Broiler Batch 8",
        bird_count=180,
        date_acquired=broiler_start,
        acquired_by="purchased",
        purchase_date=broiler_start,
        purchase_price=_dec("39600.00"),
        notes="Current meat batch. Previous batch was sold about a month ago.",
        is_archived=False,
    )
    groups = [layers, ducks, broilers]
    session.add_all(groups)
    session.flush()

    for day_offset in range(_history_start_offset(), -1, -1):
        day = today - timedelta(days=day_offset)
        session.add(
            EggProductionModel(
                poultry_group_id=layers.id,
                owner_id=owner_id,
                produced_at=_at(day, hour=9),
                quantity=_dec(_layer_eggs(day_offset)),
                unit="pcs",
                price_per_unit=_dec(EGG_PRICE),
                note="Morning collection from Layer Shed A",
            )
        )
        session.add(
            EggProductionModel(
                poultry_group_id=ducks.id,
                owner_id=owner_id,
                produced_at=_at(day, hour=9, minute=30),
                quantity=_dec(_duck_eggs(day_offset)),
                unit="pcs",
                price_per_unit=_dec(EGG_PRICE),
                note="Duck eggs from the pond",
            )
        )
        session.add(
            PoultryFeedingModel(
                poultry_group_id=layers.id,
                owner_id=owner_id,
                fed_at=_at(day, hour=8),
                feed_name="Layer mash",
                quantity=_qty(120.0),
                unit="kg",
                note="Daily ration for 1,000 hens",
            )
        )
        session.add(
            PoultryFeedingModel(
                poultry_group_id=ducks.id,
                owner_id=owner_id,
                fed_at=_at(day, hour=8, minute=20),
                feed_name="Layer mash",
                quantity=_qty(3.5),
                unit="kg",
                note="Supplement; ducks also forage on the pond",
            )
        )
        if day_offset <= BROILER_AGE_DAYS:
            session.add(
                PoultryFeedingModel(
                    poultry_group_id=broilers.id,
                    owner_id=owner_id,
                    fed_at=_at(day, hour=8, minute=40),
                    feed_name="Broiler grower",
                    quantity=_qty(16.0),
                    unit="kg",
                    note="Batch 8, on farm since purchase",
                )
            )
    return groups


def _seed_crops(session, owner_id, today: date) -> None:
    rice = CropNameModel(
        owner_id=owner_id,
        name="Boro rice",
        notes="Winter rice for wholesale and the household.",
        is_archived=False,
    )
    tomato = CropNameModel(
        owner_id=owner_id,
        name="Tomato",
        notes="Kitchen-garden tomato sold at the local haat.",
        is_archived=False,
    )
    gourd = CropNameModel(
        owner_id=owner_id,
        name="Bottle gourd",
        notes="Short-cycle vegetable along the roadside plot.",
        is_archived=False,
    )
    session.add_all([rice, tomato, gourd])
    session.flush()

    rice_cycle = CropCycleModel(
        owner_id=owner_id,
        crop_name_id=rice.id,
        plot_name="North Field",
        area=_dec("1.50"),
        location="Block A",
        planted_at=_history_start(today),
        expected_harvest_at=today + timedelta(days=21),
        notes="Still in the field. Harvest is about three weeks away.",
        is_archived=False,
    )
    tomato_cycle = CropCycleModel(
        owner_id=owner_id,
        crop_name_id=tomato.id,
        plot_name="Kitchen garden",
        area=_dec("0.25"),
        location="Beside the house",
        planted_at=today - timedelta(days=55),
        expected_harvest_at=today - timedelta(days=25),
        notes="Picking every few days for Joydebpur and Konabari.",
        is_archived=False,
    )
    gourd_cycle = CropCycleModel(
        owner_id=owner_id,
        crop_name_id=gourd.id,
        plot_name="Roadside plot",
        area=_dec("0.15"),
        location="Along the farm lane",
        planted_at=today - timedelta(days=40),
        expected_harvest_at=today - timedelta(days=14),
        notes="First fruits this fortnight. Sold by the piece at the haat.",
        is_archived=False,
    )
    session.add_all([rice_cycle, tomato_cycle, gourd_cycle])
    session.flush()

    expenses = [
        (rice_cycle, 89, "seeds", "4500.00", "Boro seed for North Field"),
        (rice_cycle, 70, "fertilizers", "3200.00", "Urea and TSP at transplanting"),
        (rice_cycle, 40, "labour", "8000.00", "Weeding gang for the rice plot"),
        (rice_cycle, 18, "irrigation", "1500.00", "Pump hire for a dry week"),
        (rice_cycle, 4, "pesticides_and_chemicals", "900.00", "Stem-borer spray"),
        (tomato_cycle, 55, "seeds", "900.00", "Tomato seedlings"),
        (tomato_cycle, 42, "fertilizers", "700.00", "Basal dose on the kitchen garden"),
        (tomato_cycle, 30, "pesticides_and_chemicals", "1100.00", "Neem spray after flowering"),
        (tomato_cycle, 12, "labour", "2500.00", "Picking and packing help"),
        (gourd_cycle, 40, "seeds", "350.00", "Bottle gourd seedlings"),
        (gourd_cycle, 28, "fertilizers", "400.00", "Light top dressing"),
        (gourd_cycle, 8, "labour", "1200.00", "Harvest and market prep"),
    ]
    for cycle, offset, category, amount, note in expenses:
        session.add(
            CropExpenseModel(
                crop_cycle_id=cycle.id,
                owner_id=owner_id,
                spent_at=today - timedelta(days=offset),
                category=category,
                amount=_dec(amount),
                note=note,
            )
        )

    markets = ("Joydebpur haat", "Konabari morning market", "regular shop buyer")
    for index, day_offset in enumerate(range(24, -1, -3)):
        kilos = 48 + (index % 4) * 6
        session.add(
            HarvestModel(
                crop_cycle_id=tomato_cycle.id,
                owner_id=owner_id,
                harvested_at=today - timedelta(days=day_offset),
                quantity=_qty(kilos),
                unit="kg",
                sale_amount=_money(kilos * 42),
                note=f"Tomato sold at {markets[index % len(markets)]}",
            )
        )
    for index, day_offset in enumerate((14, 10, 6, 2, 0)):
        pieces = 30 + index * 4
        session.add(
            HarvestModel(
                crop_cycle_id=gourd_cycle.id,
                owner_id=owner_id,
                harvested_at=today - timedelta(days=day_offset),
                quantity=_qty(pieces),
                unit="pcs",
                sale_amount=_money(pieces * 25),
                note="Bottle gourd for the haat",
            )
        )


def _seed_inventory(session, owner_id, today: date) -> None:
    # name, category, opening, unit, price, use qty, restock qty, use reason, add reason, note
    specs = [
        ("Cattle concentrate", "feed", 1600, "kg", "52.00", 80, 400, "Issued to the cattle shed", "Bought from the Gazipur feed dealer", "Concentrate for 25 cattle"),
        ("Rice straw", "feed", 2200, "kg", "8.00", 100, 500, "Fed out with the morning ration", "Brought in from the neighbour's threshing", "Roughage for the full herd"),
        ("Layer mash", "feed", 1800, "kg", "48.00", 120, 600, "Issued to Layer Shed A and the ducks", "Weekly mash delivery", "Feed for 1,000 hens"),
        ("Broiler grower", "feed", 250, "kg", "50.00", 16, 80, "Issued to Broiler Batch 8", "Restocked for the current batch", "Used only by the meat birds"),
        ("Urea", "fertilizer", 200, "kg", "32.00", 10, 50, "Top dressing on North Field", "Bought before the rice top dressing", "Rice and vegetable plots"),
        ("TSP", "fertilizer", 120, "kg", "40.00", 8, 40, "Basal dose on the kitchen garden", "Restocked with the urea", "Used at planting"),
        ("DAP", "fertilizer", 80, "kg", "58.00", 6, 25, "Side dressing on the roadside plot", "Small bag from the dealer", "Vegetables only"),
        ("Neem oil", "pesticide", 15, "L", "480.00", 0.5, 4, "Sprayed on the tomato plants", "Bought for the flowering spray", "Kitchen-garden spray"),
        ("Boro rice seed", "seed", 40, "kg", "90.00", 2, 10, "Kept back as reserve seed", "Leftover after sowing North Field", "Not all of this season's seed was sown"),
        ("Tomato seed", "seed", 3, "kg", "1800.00", 0.2, 1, "Sown for the next bed", "Extra packet from the nursery", "Kitchen garden"),
        ("Cattle dewormer", "medicine", 30, "pcs", "35.00", 1, 10, "Monthly dose for the herd", "Bought with the vet visit", "One bolus per adult cow"),
        ("Diesel", "fuel", 100, "L", "110.00", 8, 40, "Irrigation pump and the tempo", "Filled the drum in Gazipur", "Pump and market trips"),
    ]
    rows: list[dict] = []
    for name, category, opening, unit, price, use_qty, restock, use_reason, add_reason, note in specs:
        item = InventoryItemModel(
            owner_id=owner_id,
            name=name,
            category=category,
            quantity=_qty(opening),
            unit=unit,
            price_per_unit=_dec(price),
            note=note,
            is_archived=False,
        )
        session.add(item)
        rows.append(
            {
                "item": item,
                "qty": float(opening),
                "use": float(use_qty),
                "restock": float(restock),
                "use_reason": use_reason,
                "add_reason": add_reason,
            }
        )
    session.flush()

    cursor = 0
    for day_offset in range(_history_start_offset(), -1, -2):
        row = rows[cursor % len(rows)]
        cursor += 1
        day = today - timedelta(days=day_offset)
        if row["qty"] < row["use"] * 2:
            row["qty"] += row["restock"]
            session.add(
                StockUpdateModel(
                    inventory_item_id=row["item"].id,
                    owner_id=owner_id,
                    occurred_at=day,
                    change_type="add",
                    quantity_change=_qty(row["restock"]),
                    reason=row["add_reason"],
                )
            )
        row["qty"] -= row["use"]
        session.add(
            StockUpdateModel(
                inventory_item_id=row["item"].id,
                owner_id=owner_id,
                occurred_at=day,
                change_type="use",
                quantity_change=_qty(row["use"]),
                reason=row["use_reason"],
            )
        )
        row["item"].quantity = _qty(row["qty"])


def _add_ledger(
    session,
    owner_id,
    *,
    entry_type: str,
    day: date,
    category: str,
    amount: str,
    note: str,
) -> None:
    session.add(
        LedgerEntryModel(
            owner_id=owner_id,
            entry_type=entry_type,
            occurred_at=day,
            category=category,
            amount=_dec(amount),
            unit=None,
            note=note,
            is_archived=False,
        )
    )


def _seed_ledger(session, owner_id, today: date) -> None:
    """Cash book whose milk and egg lines match that day's production."""
    for day_offset in range(_history_start_offset(), -1, -1):
        day = today - timedelta(days=day_offset)
        market = "Konabari haat" if day.weekday() in (4, 5) else "regular buyers"
        liters = _day_milk_liters(day_offset)
        eggs = _layer_eggs(day_offset) + _duck_eggs(day_offset)
        milk_note = f"Milk from Rani and Moti, sold to {market}"
        if _rani_sick(day_offset):
            milk_note = f"Milk sale to {market} — Rani's yield is down after treatment"
        _add_ledger(
            session,
            owner_id,
            entry_type="income",
            day=day,
            category="product_sale",
            amount=f"{liters * 75:.2f}",
            note=milk_note,
        )
        _add_ledger(
            session,
            owner_id,
            entry_type="income",
            day=day,
            category="product_sale",
            amount=f"{eggs * 12:.2f}",
            note=f"Eggs from Layer Shed A and the pond ducks, sold to {market}",
        )
        if day_offset % 7 == 0:
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="feed_or_supplies",
                amount="52000.00",
                note="Weekly feed for 25 cattle and 1,000 hens",
            )
        if day_offset % 14 == 2:
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="labour",
                amount="4200.00",
                note="Two field hands for the plots and the sheds",
            )
        if day_offset in (60, 30, 0):
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="utilities",
                amount="2100.00",
                note="Shed lights and the irrigation pump",
            )
        if day.weekday() == 4:
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="transport",
                amount="500.00",
                note="Tempo to the Friday haat",
            )
        if day_offset == 80:
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="equipment",
                amount="6800.00",
                note="Two stainless milk cans",
            )
        if day_offset == 50:
            _add_ledger(
                session,
                owner_id,
                entry_type="income",
                day=day,
                category="subsidy",
                amount="8000.00",
                note="Upazila agriculture grant for seedlings",
            )
        if day_offset == 33:
            _add_ledger(
                session,
                owner_id,
                entry_type="income",
                day=day,
                category="livestock_sale",
                amount="62000.00",
                note="Sold finished broiler batch 7 (180 birds)",
            )
        if day_offset == 14:
            _add_ledger(
                session,
                owner_id,
                entry_type="expense",
                day=day,
                category="other",
                amount="1800.00",
                note="Vet visit and medicine for Rani",
            )


def seed(*, reset: bool) -> None:
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
        _seed_cows(session, owner.id, today)
        _seed_poultry(session, owner.id, today)
        _seed_crops(session, owner.id, today)
        _seed_inventory(session, owner.id, today)
        _seed_ledger(session, owner.id, today)
        session.commit()

        start = _history_start(today)
        print("Client demo farm loaded.")
        print("  Farm:     Green Valley Farm, Konabari, Gazipur")
        print("  Owner:    Karim Hossain")
        print(f"  Email:    {DEMO_EMAIL}")
        print(f"  Password: {DEMO_PASSWORD}")
        print(f"  Range:    {start.isoformat()} through {today.isoformat()} ({HISTORY_DAYS} days)")
        print("  Show:")
        print("    - 25 cows: 15 dual-purpose, milked twice a day; 10 meat bulls")
        print("    - Rani's yield dips 12–14 days ago")
        print("    - 1,000 Sonali hens, 28 ducks, broiler batch 8 started 32 days ago")
        print("    - Boro rice still in the field; tomato and bottle gourd are being picked")
        print("    - Ledger milk and egg sales match that day's production")
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
