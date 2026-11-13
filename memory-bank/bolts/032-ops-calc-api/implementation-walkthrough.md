---
unit: 001-ops-calc-api
bolt: 032-ops-calc-api
stage: implement
status: complete
updated: '2026-11-13T07:30:00Z'
---

# Implementation Walkthrough - 032-ops-calc-api

## Summary

Extended crops expense/harvest mutations, fertilizer-category stock listing, ledger range series, and a thin dashboard aggregates facade with farm-local timezone future-date rejection (`Asia/Dhaka` default).

## Changes

### Crops

- `CropExpenseService` / `HarvestService`: `get`, `update`, `delete` (hard-delete)
- Archived cycle blocks mutate → `409 CROP_CYCLE_ARCHIVED`
- Missing rows → `CROP_EXPENSE_NOT_FOUND` / `HARVEST_NOT_FOUND`
- Presentation: partial PATCH schemas + `PATCH`/`DELETE` on expense and harvest routes

### Inventory

- `StockUpdateService.list_by_category` — cross-item stock updates filtered by item category
- `GET /api/v1/inventory-stock-updates?category=fertilizer` returns item id/name/category on each row
- No stock-update PATCH/DELETE (compensating POST remains; out of bolt scope)

### Ledger / income_expenses

- `GET /api/v1/ledger-entries/series` — zero-filled income/expense/net buckets by `grain`
- Totals and series reject `to` after farm-local today → `422 FUTURE_DATE_NOT_ALLOWED`

### Farm clock & settings

- `app/core/farm_clock.py` — resolve farm TZ, assert not future, bucket helpers
- `farm_settings.timezone` (nullable; default `Asia/Dhaka`) + Alembic `20261113_0009`

### Dashboard (new thin module)

- `GET /api/v1/dashboard/aggregates` — series for egg_production, hen_headcount, milk, cow_production, expenses_cost, income
- Wired into `api/v1/router.py`

### Tests

- Integration: crop expense/harvest PATCH/DELETE/archive; fertilizer category list; ledger series zero-fill; dashboard aggregates + future date
- Security: unauth on new crop mutate, inventory-stock-updates list, ledger series, dashboard aggregates

## Story mapping

| Story | Delivered |
| ----- | --------- |
| 001-api-crop-expense-harvest-update-delete | Expense/harvest PATCH + DELETE |
| 002-api-fertilizer-stock-list | `GET /inventory-stock-updates?category=` |
| 003-api-ledger-range-series | `GET /ledger-entries/series` + future-date on totals |
| 004-api-dashboard-aggregates | `GET /dashboard/aggregates` + TZ bounds |

## Verification (local)

```bash
cd backend && . .venv/bin/activate && python -m pytest -q
# 64 passed
```

## Notes

- ADR skipped (reuse crops/inventory/ledger/cow mutation patterns)
- Web/mobile UI remains bolts `033` / `034`
