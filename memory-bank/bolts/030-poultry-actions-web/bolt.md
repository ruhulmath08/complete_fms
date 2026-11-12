---
id: 030-poultry-actions-web
unit: 002-poultry-actions-web
intent: 004-poultry-history-actions-and-table-polish
type: simple-construction-bolt
status: planned
stories:
  - 001-web-poultry-egg-feeding-actions
  - 002-web-history-no-and-action-colors
created: "2026-11-12T09:47:02Z"
requires_bolts:
  - 029-poultry-actions-api
enables_bolts: []
requires_units:
  - 001-poultry-actions-api
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 030-poultry-actions-web

## Objective

Wire poultry Egg/Feeding Action columns on web; rename history `#` → **No.**; Edit primary / Delete danger.

## Stories Included

- [ ] **001-web-poultry-egg-feeding-actions**: Poultry Action - Priority: Must
- [ ] **002-web-history-no-and-action-colors**: No. + colors - Priority: Must

## Expected Outputs

- PoultryDetailPage Action + API client mutations
- History table header polish across web
- Vitest updates

## Dependencies

### Requires

- **029-poultry-actions-api** (Required)
