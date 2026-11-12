---
id: 025-design-web
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
type: simple-construction-bolt
status: complete
stories:
  - 001-web-tokens-and-shell-polish
  - 002-web-universal-paginated-tables
  - 003-web-empty-loading-error
created: "2026-11-12T07:34:21Z"
started: "2026-11-12T08:39:00Z"
completed: "2026-11-12T08:42:00Z"
current_stage: null
stages_completed:
  - name: plan
    completed: "2026-11-12T08:39:00Z"
    artifact: implementation-plan.md
  - name: implement
    completed: "2026-11-12T08:42:00Z"
    artifact: implementation-walkthrough.md
  - name: test
    completed: "2026-11-12T08:42:00Z"
    artifact: test-walkthrough.md
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

- [x] **001-web-tokens-and-shell-polish**: Tokens + shell polish - Priority: Must
- [x] **002-web-universal-paginated-tables**: Universal paginated tables - Priority: Must
- [x] **003-web-empty-loading-error**: Empty/loading/error - Priority: Must

## Stages

- [x] **1. Plan**: Done → `implementation-plan.md`
- [x] **2. Implement**: Done → `implementation-walkthrough.md`
- [x] **3. Test**: Done → `test-walkthrough.md`

## Dependencies

### Enables

- 026-design-web
