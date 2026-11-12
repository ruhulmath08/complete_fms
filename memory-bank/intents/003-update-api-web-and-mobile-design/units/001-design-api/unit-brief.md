---
unit: 001-design-api
intent: 003-update-api-web-and-mobile-design
phase: inception
status: complete
created: '2026-11-12T07:34:21Z'
updated: '2026-11-12T07:34:21Z'
unit_type: backend
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: 001-design-api

## Purpose

Extend the FastAPI backend so redesigned web/mobile tables can show row **Total**s, paginate at page size 10 with meta, and **update/delete** tabular rows (milk/feeding minimum).

## Scope

### In Scope

- Feeding (and related) fields needed for a clear **Total** column
- Update and delete endpoints for cow milk and feeding entries
- Pagination metadata parity for primary entity/history lists used by tables
- OpenAPI / contract docs aligned with clients

### Out of Scope

- Unrelated domain rewrites
- New farm domains
- UI implementation (web/mobile units)

---

## Assigned Requirements

| FR    | Requirement                                                              | Priority |
| ----- | ------------------------------------------------------------------------ | -------- |
| FR-10 | API updates only to support redesign (totals, update/delete, pagination) | Must     |

---

## Domain Concepts

### Key Entities

| Entity         | Description             | Attributes                                                                |
| -------------- | ----------------------- | ------------------------------------------------------------------------- |
| MilkProduction | Cow milk history row    | quantity, price_per_unit, total (computed or stored), timestamps          |
| CowFeeding     | Cow feeding history row | feed_name, quantity, unit, unit_cost/price (as needed), total, timestamps |
| ListMeta       | Pagination envelope     | total, limit, offset                                                      |

### Key Operations

| Operation           | Description                         | Inputs           | Outputs          |
| ------------------- | ----------------------------------- | ---------------- | ---------------- |
| Update milk/feeding | Patch an existing row               | id + fields      | Updated resource |
| Delete milk/feeding | Remove a row                        | id               | 204/confirmation |
| List with meta      | Paginated lists                     | limit=10, offset | items + meta     |
| Ensure total        | Provide total for feeding/milk rows | row fields       | total value      |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 3     |
| Must Have     | 3     |
| Should Have   | 0     |
| Could Have    | 0     |

### Stories

- [x] **001-api-feeding-total-and-list-meta**: Feeding total + list pagination meta - Must - Planned
- [x] **002-api-milk-feeding-update-delete**: Milk/feeding update and delete - Must - Planned
- [x] **003-api-entity-list-pagination-parity**: Entity list pagination for tables - Must - Planned

---

## Dependencies

### Depends On

- Existing cows/platform APIs from intents 001/002

### Depended On By

- `002-design-web`, `003-design-mobile`

---

## Technical Constraints

- Prefer extending existing resources over new domains
- Breaking changes coordinated with both clients
- Default page size 10

---

## Success Criteria

- [ ] Feeding rows expose a clear Total (field or formula)
- [ ] Milk and feeding support update + delete
- [ ] Primary list/history endpoints return usable pagination meta for page size 10
- [ ] Web/mobile can implement Action column and Total without client-only hacks
