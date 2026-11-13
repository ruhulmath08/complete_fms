---
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
phase: inception
status: complete
created: '2026-11-13T07:00:00Z'
updated: '2026-11-13T07:00:00Z'
unit_type: mobile
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 003-ops-calc-mobile

## Purpose

Deliver Flutter UI for crop Expenses/Harvests Action, fertilizer-category stock table, ledger numeric totals + graph, and Dashboard as post-login landing with period controls and EN/BN strings.

## Scope

### In Scope

- Crop cycle detail: Expenses and Harvests Edit/Delete with confirm; primary/danger styling
- Inventory: fertilizer-category stock changes as cow-like table/list options
- Income & expenses: keep numeric totals; add graph below Apply date range
- Dashboard page; shell/nav; redirect after login to Dashboard (`AppRoutes`)
- Period day/week/month/year; default this week; block future dates (farm local TZ)
- EN + BN localization for new copy

### Out of Scope

- API implementation (unit `001-ops-calc-api`)
- Web UI

## Assigned Requirements

| FR | Requirement | Priority |
| ---- | ----------- | -------- |
| FR-1 | Crop expenses Action (mobile) | Must |
| FR-2 | Crop harvests Action (mobile) | Must |
| FR-3 | Fertilizer stock table (mobile) | Must |
| FR-4 | Ledger numeric + graph (mobile) | Must |
| FR-5 | Dashboard landing (mobile) | Must |
| FR-6 | Dashboard graphs (mobile) | Must |
| FR-7 | Period / no future dates (mobile) | Must |

## Story Summary

- **Total Stories**: 4
- **Must Have**: 4

### Stories

- [x] **001-mobile-crop-expense-harvest-actions**: Crop Action - Must - ✅ GENERATED
- [x] **002-mobile-fertilizer-stock-table**: Fertilizer stock table - Must - ✅ GENERATED
- [x] **003-mobile-ledger-range-graph**: Ledger graph + numeric - Must - ✅ GENERATED
- [x] **004-mobile-dashboard-and-landing**: Dashboard + landing - Must - ✅ GENERATED

## Dependencies

- Requires `001-ops-calc-api`

## Success Criteria

- [ ] Farmer can edit/delete crop expense and harvest on mobile
- [ ] Fertilizer-category stock table usable like cow history
- [ ] Ledger shows numeric totals and graph after Apply
- [ ] Login lands on Dashboard; period default this week; no future dates; EN/BN present
