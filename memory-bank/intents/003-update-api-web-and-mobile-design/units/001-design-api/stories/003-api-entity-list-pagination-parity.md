---
id: 003-api-entity-list-pagination-parity
unit: 001-design-api
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 024-design-api
implemented: false
---

# Story: 003-api-entity-list-pagination-parity

## User Story

**As a** developer building universal tables
**I want** primary entity list endpoints to support page size 10 with total meta
**So that** web/mobile can paginate all display-data tables consistently

## Acceptance Criteria

- [ ] **Given** cows, poultry, crops, inventory, and income/expenses list endpoints, **When** called with `limit=10` and `offset`, **Then** responses include items for that page and meta.total (or equivalent)
- [ ] **Given** existing milk/feeding pagination from intent `002`, **When** this story ships, **Then** those contracts remain compatible
- [ ] **Given** limit omitted, **When** listing, **Then** documented default is acceptable for clients that pass explicit 10

## Technical Notes

- Prefer extending existing list APIs over new endpoints
- Only change contracts where meta/page size is insufficient today

## Dependencies

### Requires

- None

### Enables

- Universal web tables (FR-4/FR-6)

## Edge Cases

| Scenario            | Expected Behavior                 |
| ------------------- | --------------------------------- |
| offset beyond total | Empty items, meta.total unchanged |

## Out of Scope

- UI pagination controls
