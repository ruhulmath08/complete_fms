---
unit: 002-ops-calc-web
bolt: 033-ops-calc-web
stage: implement
status: complete
updated: '2026-11-13T07:50:00Z'
---

# Implementation Walkthrough - 033-ops-calc-web

## Summary

Wired React UI for crop expense/harvest Action, fertilizer stock table, ledger range graph, and Dashboard post-login landing consuming bolt `032` APIs.

## Changes

### Shared

- `shared/ui/SeriesChart.tsx` — SVG multi-series chart (no chart npm dep)
- `shared/ui/ActionIcons.tsx`, `shared/dates.ts` — period helpers (Monday week start, clamp to today)
- Chart/dashboard styles in `index.css`

### Crops (001)

- `ExpenseUpdateInput` / `HarvestUpdateInput` + PATCH/DELETE in `cropsApi`
- `CropCycleDetailPage` Expenses/Harvests Action (Edit primary / Delete danger), edit-into-form, confirm delete

### Inventory (002)

- `listInventoryStockUpdates({ category: "fertilizer" })`
- `FertilizerStockTable` on `InventoryListPage`

### Ledger (003)

- `getLedgerSeries` + `LedgerRangeChart` below Apply; numeric totals retained

### Dashboard (004)

- `features/dashboard` page + API; `/dashboard` route; `/` redirects there
- AppShell nav first item + brand → dashboard; sign-in redirect → `/dashboard`
- Period day/week/month/year; date `max` = today; six series charts

## Story mapping

| Story | Delivered |
| ----- | --------- |
| 001-web-crop-expense-harvest-actions | Action columns + mutations |
| 002-web-fertilizer-stock-table | Paginated fertilizer table |
| 003-web-ledger-range-graph | Totals + series chart |
| 004-web-dashboard-and-landing | Landing + period graphs |

## Verification

```bash
cd web && npm test
# 21 files, 56 passed
```
