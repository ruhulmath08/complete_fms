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
updated: "2026-11-12T08:13:02Z"
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

Complete mobile production UX with **full web parity** for cow milk/feeding: pagination, **Total** + feeding **unit cost**, **Edit/Delete** wired to bolt `024` APIs, cow image/info layout, forms/a11y.

## Stories Included

- [ ] **003-mobile-detail-history-pagination**: Detail/history + pagination - Priority: Must
- [ ] **004-mobile-totals-actions-cow-layout**: Milk/feeding totals, unit cost, Edit/Delete, cow layout - Priority: Must
- [ ] **005-mobile-forms-a11y**: Forms + a11y - Priority: Should

## Expected Outputs

- Paginated milk/feeding histories with Total and feeding unit cost
- Edit/Delete affordances calling PATCH/DELETE APIs (same contracts as web)
- Cow detail rectangular image + info layout
- Form/semantics polish (including required unit cost on feeding)

## Dependencies

### Bolt Dependencies

- **024-design-api** (Required) — totals, unit_cost, PATCH/DELETE
- **027-design-mobile** (Required)
