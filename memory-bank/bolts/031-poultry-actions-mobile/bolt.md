---
id: 031-poultry-actions-mobile
unit: 003-poultry-actions-mobile
intent: 004-poultry-history-actions-and-table-polish
type: simple-construction-bolt
status: planned
stories:
  - 001-mobile-poultry-egg-feeding-actions
  - 002-mobile-history-no-and-action-colors
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

# Bolt: 031-poultry-actions-mobile

## Objective

Flutter poultry egg/feeding Edit/Delete with confirm; **No.** labeling; primary/danger Action colors; BN/EN.

## Stories Included

- [ ] **001-mobile-poultry-egg-feeding-actions**: Mobile Edit/Delete - Priority: Must
- [ ] **002-mobile-history-no-and-action-colors**: No. + colors - Priority: Must

## Expected Outputs

- Poultry detail mutations + DI/API wiring
- l10n + critical-path tests

## Dependencies

### Requires

- **029-poultry-actions-api** (Required)
