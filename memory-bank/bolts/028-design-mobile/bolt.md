---
id: 028-design-mobile
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
type: simple-construction-bolt
status: planned
stories:
  - 003-mobile-detail-history-pagination
  - 004-mobile-totals-actions-cow-layout
  - 005-mobile-forms-a11y
created: "2026-11-12T07:34:21Z"
requires_bolts:
  - 024-design-api
  - 027-design-mobile
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

# Bolt: 028-design-mobile

## Objective

Complete mobile production UX: detail/history pagination, totals/actions/cow layout parity, forms/a11y.

## Stories Included

- [ ] **003-mobile-detail-history-pagination**: Detail/history + pagination - Priority: Must
- [ ] **004-mobile-totals-actions-cow-layout**: Totals, actions, cow layout - Priority: Must
- [ ] **005-mobile-forms-a11y**: Forms + a11y - Priority: Should

## Expected Outputs

- Paginated histories with edit/delete
- Cow detail layout parity
- Form/semantics polish

## Dependencies

### Bolt Dependencies

- **024-design-api** (Required)
- **027-design-mobile** (Required)
