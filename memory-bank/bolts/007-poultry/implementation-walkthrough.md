---
stage: implement
bolt: 007-poultry
created: 2026-11-09T11:29:47Z
---

# Implementation Walkthrough: Poultry (API)

## Summary

Added `backend/app/modules/poultry/` with poultry-group CRUD/archive plus nested feeding and egg-production endpoints under `/api/v1/poultry-groups`. Persistence uses sync SQLAlchemy (ADR-002), soft-archive with write block (ADR-004), and denormalized `owner_id` on child tables (ADR-005). Group names are not unique; UUID `id` is the stable identity.

## Structure Overview

```text
backend/app/modules/poultry/
├── domain/rules.py           # type, purchase, egg, archive rules
├── application/services.py   # PoultryGroupService, PoultryFeedingService, EggProductionService
├── infrastructure/models.py  # poultry_groups, poultry_feedings, egg_productions
└── presentation/
    ├── schemas.py
    └── routers.py
```

Mounted from `app/api/v1/router.py`. Alembic revision `20261109_0003` creates the three tables and indexes.

## Completed Work

- [x] Domain rules for poultry type, purchase fields, egg eligibility, archive guard
- [x] SQLAlchemy models (no unique constraint on group name)
- [x] Application services with owner scoping and paging (`limit` 1–100, default 20)
- [x] REST routers: poultry-groups CRUD/archive, feedings, egg-productions
- [x] Error codes: `POULTRY_GROUP_NOT_FOUND`, `POULTRY_GROUP_ARCHIVED`, `EGGS_NOT_ALLOWED_FOR_TYPE`, `PURCHASE_FIELDS_INVALID`, `VALIDATION_ERROR`
- [x] Alembic migration `20261109_0003_poultry_tables.py`
- [x] Import models in `alembic/env.py` and `tests/conftest.py`

## Key Decisions

- **Names not unique** — clients always key by `group_id`
- **Child `owner_id`** set server-side from JWT owner (ADR-005)
- **Eggs blocked for broiler** via `EGGS_NOT_ALLOWED_FOR_TYPE`
- **PATCH** uses `model_fields_set` so explicit `null` clears optional fields
- **Idempotent archive**: already-archived group returns current state

## Deviations from Design

None material. Automated tests deferred to Stage 5.

## Developer Notes

- Copy `.env.example` → `.env` with a working `DATABASE_URL`, then: `alembic upgrade head`
- Module import and poultry route registration verified without DB
