---
unit: 001-design-api
bolt: 024-design-api
stage: implement
status: complete
updated: "2026-11-12T07:59:21Z"
---

# Implementation Walkthrough - 024-design-api

## Summary

Extended the cows API (and entity list defaults) for production tables: Feeding `unit_cost` + row `total`, milk/feeding PATCH/DELETE, and default list page size **10** with `meta.total` across primary entity lists.

## Changes

### Domain

- `compute_row_total(quantity, unit_price)` → quantized to 2 decimal places
- `validate_non_negative_price(..., field=)` supports `unit_cost`

### Application

- `CowFeedingService.add` requires `unit_cost`
- `MilkProductionService` / `CowFeedingService`: `get`, `update`, `delete`
- Archived cows block update/delete (`COW_ARCHIVED`)
- Missing rows → `MILK_NOT_FOUND` / `FEEDING_NOT_FOUND`
- Cow list service default limit **10**

### Infrastructure

- `cow_feedings.unit_cost` Numeric(12,2) NOT NULL (default 0)
- Alembic `20261112_0008_cow_feeding_unit_cost` (add → backfill 0 → NOT NULL)

### Presentation

- Milk/feeding responses include computed **`total`**
- Feeding create/update/response include **`unit_cost`**
- `PATCH/DELETE /api/v1/cows/{cow_id}/milk-productions/{milk_id}`
- `PATCH/DELETE /api/v1/cows/{cow_id}/feedings/{feeding_id}`
- Entity list routers default `Query(10)` for cows, poultry, crops, inventory, income/expenses (and nested list endpoints in those modules)

## Story mapping

| Story                                 | Delivered                                                        |
| ------------------------------------- | ---------------------------------------------------------------- |
| 001-api-feeding-total-and-list-meta   | `unit_cost`, `total` on feeding/milk; list meta unchanged/intact |
| 002-api-milk-feeding-update-delete    | PATCH + DELETE for milk and feeding                              |
| 003-api-entity-list-pagination-parity | Default limit 10 + existing `meta.total` on entity lists         |

## Verification (local)

```bash
cd backend && . .venv/bin/activate && python -m pytest -q
# 60 passed
```

Apply migration on real Postgres before client smoke tests:

```bash
cd backend && alembic upgrade head
```

## Out of scope / follow-ups

- Web/mobile Action column UI (bolts 026 / 028)
- Soft-delete for sub-records
