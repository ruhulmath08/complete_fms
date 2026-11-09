---
stage: implement
bolt: 013-inventory
created: 2026-11-09T12:43:00Z
---

# Implementation Walkthrough: Inventory (API)

## Summary

Added inventory items and stock updates to the FastAPI modular monolith: CRUD/archive for items, add/list stock updates that adjust quantity, computed `total_price`, and `INSUFFICIENT_STOCK` when a use would go negative.

## Structure Overview

New module `backend/app/modules/inventory/` with domain rules, application services, SQLAlchemy models, and routers under `/api/v1/inventory-items`. Migration `20261109_0005` creates `inventory_items` and `stock_updates`.

## Completed Work

- [x] Domain rules: category/change-type enums, stock math, archive guard, quantized total price
- [x] `InventoryItemService` / `StockUpdateService`
- [x] Models + Alembic migration after crops
- [x] Schemas/routers wired in `api/v1/router.py`
- [x] Unit, integration, and authz tests (7 new; full suite 51)

## Key Decisions

- **No quantity on PATCH** — only create initial quantity + stock updates
- **`total_price` computed** on response (`quantity × price_per_unit`, 2 dp)
- **Reuse ADR-004/005** — no new ADR (Stage 3 skipped)

## Deviations from Design

None material.

## Developer Notes

- Apply migration `20261109_0005` before client bolts
- `pytest` verified after implementation
