---
id: 033-ops-calc-web
unit: 002-ops-calc-web
intent: 005-resolve-operations-and-calculations-issue
type: simple-construction-bolt
status: complete
stories:
  - 001-web-crop-expense-harvest-actions
  - 002-web-fertilizer-stock-table
  - 003-web-ledger-range-graph
  - 004-web-dashboard-and-landing
created: '2026-11-13T07:00:00Z'
started: '2026-11-13T07:40:00Z'
completed: '2026-11-13T07:55:00Z'
current_stage: null
stages_completed:
  - stage: plan
    completed_at: '2026-11-13T07:40:00Z'
    artifact: implementation-plan.md
  - stage: implement
    completed_at: '2026-11-13T07:50:00Z'
    artifact: implementation-walkthrough.md
  - stage: test
    completed_at: '2026-11-13T07:55:00Z'
    artifact: test-walkthrough.md
requires_bolts:
  - 032-ops-calc-api
enables_bolts: []
requires_units:
  - 001-ops-calc-api
blocks: true
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 033-ops-calc-web

## Objective

Deliver React crop Action columns, fertilizer stock table, ledger numeric+graph, and Dashboard post-login landing with period controls.

## Stories Included

- [x] **001-web-crop-expense-harvest-actions**: Crop Action - Priority: Must
- [x] **002-web-fertilizer-stock-table**: Fertilizer stock table - Priority: Must
- [x] **003-web-ledger-range-graph**: Ledger graph + numeric - Priority: Must
- [x] **004-web-dashboard-and-landing**: Dashboard + landing - Priority: Must

## Stages

- [x] **1. Implementation plan** → `implementation-plan.md`
- [x] **2. Implement** → `implementation-walkthrough.md`
- [x] **3. Test** → `test-walkthrough.md`

## Dependencies

### Requires

- 032-ops-calc-api
- Unit `001-ops-calc-api`
