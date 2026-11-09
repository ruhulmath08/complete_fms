---
stage: implement
bolt: 016-income-expenses
created: 2026-11-09T13:20:36Z
---

# Implementation Walkthrough: Income and Expenses (API)

## Summary

Added general ledger entries to the FastAPI modular monolith: CRUD/archive for income/expense lines, period totals for a date range, and `total_price` equal to `amount` on read. Crop-module expenses are not queried or included.

## Structure Overview

New module `backend/app/modules/income_expenses/` with domain rules, application services, SQLAlchemy model, and routers under `/api/v1/ledger-entries` (including `/totals`). Migration `20261109_0006` creates `ledger_entries`.

## Completed Work

- [x] Domain rules: entry type/category enums, positive amount, date range, archive guard, net
- [x] `LedgerEntryService` / `PeriodTotalsService`
- [x] Model + Alembic migration after inventory
- [x] Schemas/routers wired in `api/v1/router.py`; models imported in alembic/env and tests conftest
- [x] Unit, integration, and authz tests (6 new; full suite 57)

## Key Decisions

- **`amount` is money**; **`total_price` mirrors amount** on response (not a DB column)
- **Totals exclude archived** and only sum `ledger_entries`
- **Reuse ADR-004** — no new ADR (Stage 3 skipped)

## Deviations from Design

None material.

## Developer Notes

- Apply migration `20261109_0006` before client bolts
- `pytest` verified after implementation (57 passed)
