---
stage: implement
bolt: 010-crops
created: 2026-11-09T12:07:28Z
---

# Implementation Walkthrough: Crops (API)

## Summary

Added `backend/app/modules/crops/` with crop-name catalog CRUD/archive, crop-cycle CRUD/archive + summary, and nested expense/harvest add+list under `/api/v1`. Persistence uses sync SQLAlchemy (ADR-002), soft-archive write blocks (ADR-004), denormalized child `owner_id` (ADR-005), and active-only crop-name uniqueness (ADR-007).

## Structure Overview

```text
backend/app/modules/crops/
├── domain/rules.py
├── application/services.py
├── infrastructure/models.py
└── presentation/
    ├── schemas.py
    └── routers.py
```

Mounted from `app/api/v1/router.py`. Alembic revision `20261109_0004` creates four tables and indexes.

## Completed Work

- [x] Domain rules for categories, amounts, archive guards, name validation
- [x] SQLAlchemy models + partial unique index on active crop names
- [x] Services: CropName, CropCycle (+ summary), CropExpense, Harvest
- [x] REST: `/crop-names`, `/crop-cycles` (+ expenses, harvests, summary)
- [x] Error codes: `CROP_NAME_*`, `CROP_CYCLE_ARCHIVED`, `VALIDATION_ERROR`
- [x] Alembic `20261109_0004_crops_tables.py`
- [x] Imports in `alembic/env.py` and `tests/conftest.py`

## Key Decisions

- **Active name uniqueness** via partial unique index (ADR-007)
- **Summary** computed with SUM; null sale_amount excluded from sum (treated as 0 via coalesce)
- **Expenses/harvests** add+list only
- **Archived crop name** cannot be selected for new/updated cycles (`422`)

## Deviations from Design

None material. Automated tests deferred to Stage 5.

## Developer Notes

- `alembic upgrade head` after setting `DATABASE_URL`
- OpenAPI crop routes verified; prior backend suite still green with new tables registered
