---
id: 032-ops-calc-api
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-crop-expense-harvest-update-delete
  - 002-api-fertilizer-stock-list
  - 003-api-ledger-range-series
  - 004-api-dashboard-aggregates
created: '2026-11-13T07:00:00Z'
started: '2026-11-13T07:05:00Z'
completed: '2026-11-13T07:22:51Z'
current_stage: null
stages_completed:
  - stage: domain-model
    completed_at: '2026-11-13T07:10:00Z'
    artifact: ddd-01-domain-model.md
  - stage: design
    completed_at: '2026-11-13T07:15:00Z'
    artifact: ddd-02-technical-design.md
  - stage: adr-analysis
    completed_at: '2026-11-13T07:15:00Z'
    artifact: null
    note: skipped — reuse crops/inventory/ledger/cow mutation patterns; no new ADR
  - stage: implement
    completed_at: '2026-11-13T07:30:00Z'
    artifact: implementation-walkthrough.md
  - stage: test
    completed_at: '2026-11-13T07:35:00Z'
    artifact: ddd-03-test-report.md
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

- [x] **001-api-crop-expense-harvest-update-delete**: Crop expense/harvest PATCH/DELETE - Priority: Must
- [x] **002-api-fertilizer-stock-list**: Fertilizer-category stock list - Priority: Must
- [x] **003-api-ledger-range-series**: Ledger range series - Priority: Must
- [x] **004-api-dashboard-aggregates**: Dashboard aggregates + TZ bounds - Priority: Must

## Stages

- [x] **1. Domain model** → `ddd-01-domain-model.md`
- [x] **2. Technical design** → `ddd-02-technical-design.md`
- [x] **3. ADR analysis**: Skipped (no new ADR)
- [x] **4. Implement** → `implementation-walkthrough.md`
- [x] **5. Test report** → `ddd-03-test-report.md`

## Dependencies

### Enables

- 033-ops-calc-web
- 034-ops-calc-mobile
