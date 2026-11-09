---
stage: implement
bolt: 014-inventory
created: 2026-11-09T13:05:00Z
---

# Implementation Walkthrough: Inventory (Web)

## Summary

Added inventory management to the React SPA: list/create/edit/archive items and record/review stock add/use updates under protected routes, using shared API client and ErrorBanner patterns.

## Structure Overview

New feature folder `web/src/features/inventory` with types, API wrappers, item form (quantity only on create), and list/create/detail pages. Detail hosts stock updates. App shell nav and home CTA point to inventory.

## Completed Work

- [x] Types + `inventoryApi.ts`
- [x] `InventoryItemForm` (create vs edit; no quantity on edit)
- [x] List / create / detail pages with stock updates section
- [x] Routes `/inventory`, `/inventory/new`, `/inventory/:itemId`
- [x] AppShell + HomePage CTAs
- [x] Vitest: list success/error; form quantity visibility

## Key Decisions

- **Quantity only on create**; later changes via stock updates (matches API)
- **Hide writes when archived**; surface `INSUFFICIENT_STOCK` via ErrorBanner
- **Show `total_price`** from API on list and detail

## Deviations from Plan

None material. Stage 3 test walkthrough still pending.

## Developer Notes

- `npm test -- --run src/features/inventory` and `npm run build` verified
