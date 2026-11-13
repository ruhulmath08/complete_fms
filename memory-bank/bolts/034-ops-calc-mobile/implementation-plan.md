---
stage: plan
bolt: 034-ops-calc-mobile
created: '2026-11-13T08:00:00Z'
---

# Implementation Plan: 034-ops-calc-mobile

## Objective

Wire Flutter UI for crop expense/harvest Action, fertilizer-category stock table, ledger numeric totals + range graph, and Dashboard as post-login landing with period controls and EN/BN strings, consuming bolt `032` APIs.

## Stories

- **001-mobile-crop-expense-harvest-actions**: Crop Expenses/Harvests Action
- **002-mobile-fertilizer-stock-table**: Fertilizer stock history table
- **003-mobile-ledger-range-graph**: Ledger totals + series graph
- **004-mobile-dashboard-and-landing**: Dashboard landing + period graphs

## Deliverables

1. Crops API/repo/use-cases PATCH/DELETE; DataTable Action on `crop_cycle_detail_page` mirroring cow/poultry (031)
2. Cross-item fertilizer stock list API + paginated DataTable on inventory list
3. Ledger series API + chart below Apply; keep numeric totals
4. New dashboard feature + route; shell nav; post-login → dashboard; period day/week/month/year default this week; block future dates; EN/BN l10n
5. Critical-path tests (l10n + mapper / widget where practical)

## Dependencies

- **032-ops-calc-api** (complete)
- Patterns: `cow_detail_page` / `poultry_detail_page` (031); web 033 for API parity
- Chart: CustomPainter / lightweight custom series chart (no mandatory new package)

## Technical Approach

1. Extend crops datasource → repository → use cases → DI → detail page DataTable + edit-into-form + confirm delete
2. Inventory: `GET /inventory-stock-updates?category=fertilizer` through layers; table widget on list page
3. Ledger: series endpoint + shared series chart widget under Apply
4. Dashboard aggregates API + page; update `app_routes` / `app_router` / `sign_in_page` / `app_shell`; replace `/home` landing with dashboard (keep language controls accessible)
5. Add arb keys EN/BN; `flutter gen-l10n`; run `flutter test`

## Acceptance Criteria

- [ ] Expense/harvest Edit (primary) + Delete (danger) with confirm; refresh lists
- [ ] Fertilizer stock table paginated; empty state OK
- [ ] Apply updates totals + graph without errors on empty range
- [ ] Login lands on Dashboard; nav entry; default this week; no future dates; six series areas; EN/BN
- [ ] Critical-path tests pass

## Out of Scope

- Soft-delete; stock-update PATCH/DELETE
- Web (bolt `033`, already complete)
