---
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
phase: inception
status: ready
created: '2026-11-13T07:00:00Z'
updated: '2026-11-13T07:00:00Z'
unit_type: backend
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: 001-ops-calc-api

## Purpose

Provide owner-scoped FastAPI mutations and aggregates so web/mobile can deliver crop history Action, fertilizer-category stock tables, ledger graphs, and Dashboard analytics with farm-local-TZ date bounds.

## Scope

### In Scope

- Crop expense and harvest PATCH/DELETE (hard-delete; archive/authz parity with cows)
- List/filter stock updates for inventory items in the fertilizer category (mutations if Action requires)
- Ledger date-range series supporting income/expenses/net graph (extend totals API if needed)
- Dashboard aggregates: egg production, hen headcount, milk, cow production, expenses/cost, income
- Reject aggregate/mutation date bounds after “today” in farm local TZ
- Automated API tests

### Out of Scope

- Soft-delete
- Web/mobile UI
- Unrelated API surface

## Assigned Requirements

| FR | Requirement | Priority |
| ---- | ----------- | -------- |
| FR-1 | Crop expenses Action (API) | Must |
| FR-2 | Crop harvests Action (API) | Must |
| FR-3 | Fertilizer-category stock (API) | Must |
| FR-4 | Ledger range series (API) | Must |
| FR-6 | Dashboard aggregates (API) | Must |
| FR-7 | Future-date rejection (API) | Must |
| FR-8 | API only as needed | Must |

## Domain Concepts

| Entity / Op | Description |
| ----------- | ----------- |
| CropExpense / Harvest | Cycle history rows |
| StockUpdate | Inventory stock change rows |
| PeriodTotals / series | Ledger income/expense/net over time |
| DashboardAggregate | Period-bucketed production and money series |
| Farm local TZ | Source of “today” / this week / future rejection |

## Story Summary

- **Total Stories**: 4
- **Must Have**: 4

### Stories

- [x] **001-api-crop-expense-harvest-update-delete**: Crop expense/harvest PATCH/DELETE - Must - ✅ GENERATED
- [x] **002-api-fertilizer-stock-list**: Fertilizer-category stock list - Must - ✅ GENERATED
- [x] **003-api-ledger-range-series**: Ledger range series for graph - Must - ✅ GENERATED
- [x] **004-api-dashboard-aggregates**: Dashboard aggregates + TZ bounds - Must - ✅ GENERATED

## Dependencies

- Extends crops, inventory, ledger, cows, poultry, farm-settings modules from intents `001`–`004`
- Enables `002-ops-calc-web`, `003-ops-calc-mobile`

## Success Criteria

- [ ] Crop expense/harvest PATCH+DELETE with owner/archive tests
- [ ] Fertilizer-category stock changes listable with pagination meta
- [ ] Ledger series supports client graph for income/expenses/net
- [ ] Dashboard aggregates cover six series; future end bounds rejected in farm local TZ
