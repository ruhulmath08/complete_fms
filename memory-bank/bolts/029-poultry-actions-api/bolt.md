---
id: 029-poultry-actions-api
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-egg-update-delete
  - 002-api-poultry-feeding-update-delete
created: "2026-11-12T09:47:02Z"
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

## Expected Outputs

- Domain/service/router mutations + tests
- Hard-delete; archived group blocked

## Dependencies

### Enables

- 030-poultry-actions-web
- 031-poultry-actions-mobile
