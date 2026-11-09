---
stage: implement
bolt: 004-cows
created: 2026-11-09T10:36:09Z
---

# Implementation Walkthrough: Cows (API)

## Summary

Added `backend/app/modules/cows/` with cow CRUD/archive plus nested milk production and feeding endpoints under `/api/v1/cows`. Persistence uses sync SQLAlchemy (ADR-002), soft-archive with write block (ADR-004), denormalized `owner_id` on child tables (ADR-005), and active-only tag uniqueness via partial unique index (ADR-006).

## Structure Overview

```text
backend/app/modules/cows/
├── domain/rules.py           # purpose, gender, purchase, milk, archive rules
├── application/services.py   # CowService, MilkProductionService, CowFeedingService
├── infrastructure/models.py  # cows, milk_productions, cow_feedings
└── presentation/
    ├── schemas.py
    └── routers.py
```

Mounted from `app/api/v1/router.py`. Alembic revision `20261109_0002` creates the three tables and indexes.

## Completed Work

- [x] Domain rules for enums, purchase fields, milk eligibility, archive guard
- [x] SQLAlchemy models + partial unique index on active tags
- [x] Application services with owner scoping and paging (`limit` 1–100, default 20)
- [x] REST routers: cows CRUD/archive, milk-productions, feedings
- [x] Error codes: `TAG_ALREADY_EXISTS`, `COW_ARCHIVED`, `MILK_NOT_ALLOWED_FOR_PURPOSE`, `PURCHASE_FIELDS_INVALID`, `COW_NOT_FOUND`
- [x] Alembic migration `20261109_0002_cows_tables.py`
- [x] Import models in `alembic/env.py`

## Key Decisions

- **Partial unique index** for tags among active cows only (ADR-006)
- **Child `owner_id`** set server-side from JWT owner (ADR-005)
- **PATCH** uses `model_fields_set` so explicit `null` clears optional fields
- **Idempotent archive**: already-archived cow returns current state

## Deviations from Design

None material. Automated tests deferred to Stage 5.

## Developer Notes

- Copy `.env.example` → `.env` with a working `DATABASE_URL`, then: `alembic upgrade head`
- Module import and route registration verified without DB; local migrate failed here due to Postgres auth (no `.env` / password mismatch) — run migrate on your DB before Stage 5 API tests
