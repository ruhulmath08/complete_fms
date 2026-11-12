---
id: 024-design-api
unit: 001-design-api
intent: 003-update-api-web-and-mobile-design
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-feeding-total-and-list-meta
  - 002-api-milk-feeding-update-delete
  - 003-api-entity-list-pagination-parity
created: "2026-11-12T07:34:21Z"
requires_bolts: []
enables_bolts:
  - 026-design-web
  - 028-design-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 024-design-api

## Objective

Deliver API support for Feeding Total, milk/feeding update/delete, and entity list pagination meta for production tables.

## Stories Included

- [ ] **001-api-feeding-total-and-list-meta**: Feeding total + list meta - Priority: Must
- [ ] **002-api-milk-feeding-update-delete**: Milk/feeding update and delete - Priority: Must
- [ ] **003-api-entity-list-pagination-parity**: Entity list pagination parity - Priority: Must

## Expected Outputs

- Domain/technical design for totals and mutations
- Implemented endpoints + migrations as needed
- Test report covering update/delete and pagination meta

## Dependencies

### Bolt Dependencies

- None

### Enables

- 026-design-web
- 028-design-mobile
