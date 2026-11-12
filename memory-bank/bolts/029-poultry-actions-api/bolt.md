---
id: 029-poultry-actions-api
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-egg-update-delete
  - 002-api-poultry-feeding-update-delete
created: "2026-11-12T09:47:02Z"
started: "2026-11-12T09:51:00Z"
completed: "2026-11-12T09:55:00Z"
current_stage: null
stages_completed:
  - stage: domain-model
    completed_at: "2026-11-12T09:51:00Z"
    artifact: ddd-01-domain-model.md
  - stage: design
    completed_at: "2026-11-12T09:52:00Z"
    artifact: ddd-02-technical-design.md
  - stage: adr-analysis
    completed_at: "2026-11-12T09:54:00Z"
    artifact: null
    note: skipped — reuse existing poultry + cow mutation patterns
  - stage: implement
    completed_at: "2026-11-12T09:55:00Z"
    artifact: implementation-walkthrough.md
  - stage: test
    completed_at: "2026-11-12T09:55:00Z"
    artifact: ddd-03-test-report.md
requires_bolts: []
enables_bolts:
  - 030-poultry-actions-web
  - 031-poultry-actions-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 1
  testing_scope: 2
---

# Bolt: 029-poultry-actions-api

## Objective

Deliver FastAPI PATCH/DELETE for poultry egg productions and poultry feedings with archive/authz parity to cow milk/feeding.

## Stories Included

- [x] **001-api-egg-update-delete**: Egg update/delete - Priority: Must
- [x] **002-api-poultry-feeding-update-delete**: Feeding update/delete - Priority: Must

## Stages

- [x] **1. Domain model**: Done → `ddd-01-domain-model.md`
- [x] **2. Technical design**: Done → `ddd-02-technical-design.md`
- [x] **3. ADR analysis**: Skipped (no new ADR)
- [x] **4. Implement**: Done → `implementation-walkthrough.md`
- [x] **5. Test report**: Done → `ddd-03-test-report.md`

## Dependencies

### Enables

- 030-poultry-actions-web
- 031-poultry-actions-mobile
