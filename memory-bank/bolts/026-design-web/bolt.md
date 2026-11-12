---
id: 026-design-web
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
type: simple-construction-bolt
status: planned
stories:
  - 004-web-table-totals-and-actions
  - 005-web-cow-detail-chrome
  - 006-web-forms-a11y-docs
created: "2026-11-12T07:34:21Z"
requires_bolts:
  - 024-design-api
  - 025-design-web
enables_bolts: []
requires_units:
  - 001-design-api
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 3
  testing_scope: 2
---

# Bolt: 026-design-web

## Objective

Complete web production UX: table Totals + Action Edit/Delete, cow detail chrome (image/info, no Back links, Edit/Archive), forms/a11y/docs.

## Stories Included

- [ ] **004-web-table-totals-and-actions**: Totals + Action column - Priority: Must
- [ ] **005-web-cow-detail-chrome**: Cow layout, Back removal, Edit/Archive - Priority: Must
- [ ] **006-web-forms-a11y-docs**: Forms, a11y, developer docs - Priority: Should

## Expected Outputs

- Wired Action column to API update/delete
- Cow detail layout + global Back-link removal
- Short developer pattern notes

## Dependencies

### Bolt Dependencies

- **024-design-api** (Required): Totals + update/delete
- **025-design-web** (Required): Tables/shell foundation
