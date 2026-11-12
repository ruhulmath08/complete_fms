---
id: 029-poultry-actions-api
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
type: ddd-construction-bolt
status: in-progress
stories:
  - 001-api-egg-update-delete
  - 002-api-poultry-feeding-update-delete
created: "2026-11-12T09:47:02Z"
started: "2026-11-12T09:51:00Z"
completed: null
current_stage: design
stages_completed:
  - stage: domain-model
    completed_at: "2026-11-12T09:51:00Z"
    artifact: ddd-01-domain-model.md
  - stage: design
    completed_at: "2026-11-12T09:52:00Z"
    artifact: ddd-02-technical-design.md
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

- [ ] **001-api-egg-update-delete**: Egg update/delete - Priority: Must
- [ ] **002-api-poultry-feeding-update-delete**: Feeding update/delete - Priority: Must

## Stages

- [x] **1. Domain model**: Done → `ddd-01-domain-model.md`
- [x] **2. Technical design**: Done → `ddd-02-technical-design.md` (awaiting approval)
- [ ] **3. ADR analysis**: Pending (expect skip)
- [ ] **4. Implement**: Pending
- [ ] **5. Test report**: Pending

## Dependencies

### Enables

- 030-poultry-actions-web
- 031-poultry-actions-mobile
