---
unit: 002-ops-calc-web
intent: 005-resolve-operations-and-calculations-issue
phase: inception
status: complete
created: '2026-11-13T07:00:00Z'
updated: '2026-11-13T07:00:00Z'
unit_type: web
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 002-ops-calc-web

## Purpose

Deliver React UI for crop Expenses/Harvests Action, fertilizer-category stock table, ledger numeric totals + graph, and Dashboard as post-login landing with period controls.

## Scope

### In Scope

- Crop cycle detail: Expenses and Harvests Action (Edit primary / Delete danger / confirm)
- Inventory: fertilizer-category stock changes as cow-like paginated table
- Income & expenses: keep numeric Total income / expenses / Net; add graph below Apply date range
- Dashboard page; shell/nav entry; redirect after login to Dashboard
- Period day/week/month/year; default this week; block future dates (farm local TZ)
- Critical-path tests / docs note if patterns documented

### Out of Scope

- API implementation (unit `001-ops-calc-api`)
- Mobile UI

## Assigned Requirements

| FR | Requirement | Priority |
| ---- | ----------- | -------- |
| FR-1 | Crop expenses Action (web) | Must |
| FR-2 | Crop harvests Action (web) | Must |
| FR-3 | Fertilizer stock table (web) | Must |
| FR-4 | Ledger numeric + graph (web) | Must |
| FR-5 | Dashboard landing (web) | Must |
| FR-6 | Dashboard graphs (web) | Must |
| FR-7 | Period / no future dates (web) | Must |

## Story Summary

- **Total Stories**: 4
- **Must Have**: 4

### Stories

- [x] **001-web-crop-expense-harvest-actions**: Crop Action - Must - ✅ GENERATED
- [x] **002-web-fertilizer-stock-table**: Fertilizer stock table - Must - ✅ GENERATED
- [x] **003-web-ledger-range-graph**: Ledger graph + numeric - Must - ✅ GENERATED
- [x] **004-web-dashboard-and-landing**: Dashboard + landing - Must - ✅ GENERATED

## Dependencies

- Requires `001-ops-calc-api`

## Success Criteria

- [ ] Farmer can edit/delete crop expense and harvest on web
- [ ] Fertilizer-category stock table usable like cow history
- [ ] Ledger shows numeric totals and graph after Apply
- [ ] Login lands on Dashboard; period default this week; no future dates
