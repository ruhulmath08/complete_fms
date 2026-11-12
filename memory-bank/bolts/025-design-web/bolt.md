---
id: 025-design-web
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
type: simple-construction-bolt
status: planned
stories:
  - 001-web-tokens-and-shell-polish
  - 002-web-universal-paginated-tables
  - 003-web-empty-loading-error
created: "2026-11-12T07:34:21Z"
requires_bolts: []
enables_bolts:
  - 026-design-web
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 025-design-web

## Objective

Ship web foundation for production design: tokens/shell polish, universal paginated tables, and shared empty/loading/error states.

## Stories Included

- [ ] **001-web-tokens-and-shell-polish**: Tokens + shell polish - Priority: Must
- [ ] **002-web-universal-paginated-tables**: Universal paginated tables - Priority: Must
- [ ] **003-web-empty-loading-error**: Empty/loading/error - Priority: Must

## Expected Outputs

- Implementation plan + walkthrough + test notes
- Updated shell/CSS and list pages using shared table/state patterns

## Dependencies

### Bolt Dependencies

- None required to start (table meta improves after 024; may complete 002 story after 024)

### Enables

- 026-design-web

### Notes

- Full pagination accuracy for all entity lists should verify against 024
