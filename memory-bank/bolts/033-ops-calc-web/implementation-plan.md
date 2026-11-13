---
stage: plan
bolt: 033-ops-calc-web
created: '2026-11-13T07:40:00Z'
---

# Implementation Plan: 033-ops-calc-web

## Objective

Wire React UI for crop expense/harvest Action, fertilizer-category stock table, ledger numeric totals + range graph, and Dashboard as post-login landing with period controls (no future dates), consuming bolt `032` APIs.

## Stories

- **001-web-crop-expense-harvest-actions**: Crop Expenses/Harvests Action
- **002-web-fertilizer-stock-table**: Fertilizer stock history table
- **003-web-ledger-range-graph**: Ledger totals + series graph
- **004-web-dashboard-and-landing**: Dashboard landing + period graphs

## Deliverables

1. Crop `ExpenseUpdateInput` / `HarvestUpdateInput` + PATCH/DELETE in `cropsApi`; Action columns on `CropCycleDetailPage` mirroring cow/poultry
2. `listStockUpdatesByCategory` API + paginated fertilizer stock table on inventory list (or dedicated section)
3. Ledger `getLedgerSeries` + chart below Apply on `LedgerListPage`; keep numeric totals
4. New `features/dashboard` page + API; AppShell nav; sign-in/sign-up redirect to `/dashboard`; period day/week/month/year default this week; `max` on date inputs = today
5. Vitest critical-path coverage for Action, fertilizer table empty/list, ledger graph mount, dashboard redirect/period

## Dependencies

- **032-ops-calc-api** (complete)
- Patterns: `CowDetailPage` / `PoultryDetailPage` Action UX; `LedgerListPage` date Apply; `AppShell` nav

## Technical Approach

1. Extend `cropsApi` / types; port milk/feeding Action pattern into Expenses/Harvests sections
2. Extend `inventoryApi` for `GET /inventory-stock-updates?category=fertilizer`; table with PaginationControls + EmptyState
3. Extend `ledgerApi` for series; SVG/CSS line or multi-series chart component (no new chart dependency unless needed)
4. Add `dashboardApi` + `DashboardPage` with six series panels; compute week bounds in farm-local sense (browser local / document TZ note; API returns timezone)
5. Update `App.tsx`, `AppShell.tsx`, `SignInPage`/`SignUpPage` redirects; keep `/` as redirect to dashboard or replace HomePage

## Acceptance Criteria

- [ ] Expense/harvest Edit primary + Delete danger; PATCH/DELETE refresh; confirm on delete
- [ ] Fertilizer stock table paginated; non-fertilizer excluded; empty state OK
- [ ] Apply range updates numeric totals and graph without errors on empty range
- [ ] Login lands on Dashboard; nav entry; default this week; future dates blocked; six graph areas present
- [ ] Critical-path Vitest passes

## Out of Scope

- Mobile (bolt `034`)
- Stock-update PATCH/DELETE
- Soft-delete
