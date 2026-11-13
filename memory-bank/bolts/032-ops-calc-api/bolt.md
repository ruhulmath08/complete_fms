---
id: 032-ops-calc-api
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-crop-expense-harvest-update-delete
  - 002-api-fertilizer-stock-list
  - 003-api-ledger-range-series
  - 004-api-dashboard-aggregates
created: '2026-11-13T07:00:00Z'
started: null
completed: null
current_stage: null
stages_completed: []
requires_bolts: []
enables_bolts:
  - 033-ops-calc-web
  - 034-ops-calc-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 032-ops-calc-api

## Objective

Deliver FastAPI crop expense/harvest mutations, fertilizer-category stock listing, ledger range series, and dashboard aggregates with farm-local-TZ future-date rejection.

## Stories Included

- [ ] **001-api-crop-expense-harvest-update-delete**: Crop expense/harvest PATCH/DELETE - Priority: Must
- [ ] **002-api-fertilizer-stock-list**: Fertilizer-category stock list - Priority: Must
- [ ] **003-api-ledger-range-series**: Ledger range series - Priority: Must
- [ ] **004-api-dashboard-aggregates**: Dashboard aggregates + TZ bounds - Priority: Must

## Stages

- [ ] **1. Domain model** → `ddd-01-domain-model.md`
- [ ] **2. Technical design** → `ddd-02-technical-design.md`
- [ ] **3. ADR analysis** (skip if reusing patterns)
- [ ] **4. Implement** → `implementation-walkthrough.md`
- [ ] **5. Test report** → `ddd-03-test-report.md`

## Dependencies

### Enables

- 033-ops-calc-web
- 034-ops-calc-mobile
