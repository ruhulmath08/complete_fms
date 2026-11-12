---
id: 001-api-feeding-total-and-list-meta
unit: 001-design-api
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 024-design-api
implemented: false
---

# Story: 001-api-feeding-total-and-list-meta

## User Story

**As a** farm owner (via web/mobile)
**I want** feeding rows (and list APIs) to expose a clear **Total** and pagination meta
**So that** tables can show totals and page reliably like Milk production

## Acceptance Criteria

- [ ] **Given** a cow feeding entry with quantity and unit cost/price fields, **When** it is returned by the API, **Then** a **Total** is present or unambiguously computable
- [ ] **Given** milk entries already expose total (or quantity × price), **When** listed, **Then** that behavior remains intact
- [ ] **Given** a paginated list request with `limit=10`, **When** results are returned, **Then** `meta` includes at least `total`, `limit`, and `offset` (or documented equivalents)
- [ ] **Given** feeding lacks a stored unit cost, **When** construction designs the model, **Then** API is extended so Total is supportable (not left as a silent UI guess)

## Technical Notes

- Align Feeding Total with Milk: prefer `quantity × unit_price/cost`
- May require Alembic migration for unit cost on feeding

## Dependencies

### Requires

- None

### Enables

- Web/mobile Total columns (FR-12)

## Edge Cases

| Scenario                      | Expected Behavior                                                      |
| ----------------------------- | ---------------------------------------------------------------------- |
| Zero quantity                 | Total is zero                                                          |
| Missing cost before migration | Reject create/update or default per technical design — document choice |

## Out of Scope

- UI table rendering
