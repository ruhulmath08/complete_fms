---
id: 034-ops-calc-mobile
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
type: simple-construction-bolt
status: planned
stories:
  - 001-mobile-crop-expense-harvest-actions
  - 002-mobile-fertilizer-stock-table
  - 003-mobile-ledger-range-graph
  - 004-mobile-dashboard-and-landing
created: '2026-11-13T07:00:00Z'
started: null
completed: null
current_stage: null
stages_completed: []
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

# Bolt: 034-ops-calc-mobile

## Objective

Deliver Flutter crop Action flows, fertilizer stock table, ledger numeric+graph, and Dashboard post-login landing with period controls and EN/BN strings.

## Stories Included

- [ ] **001-mobile-crop-expense-harvest-actions**: Crop Action - Priority: Must
- [ ] **002-mobile-fertilizer-stock-table**: Fertilizer stock table - Priority: Must
- [ ] **003-mobile-ledger-range-graph**: Ledger graph + numeric - Priority: Must
- [ ] **004-mobile-dashboard-and-landing**: Dashboard + landing - Priority: Must

## Stages

- [ ] **1. Implementation plan** → `implementation-plan.md`
- [ ] **2. Implement** → `implementation-walkthrough.md`
- [ ] **3. Test** → `test-walkthrough.md`

## Dependencies

### Requires

- 032-ops-calc-api
- Unit `001-ops-calc-api`
