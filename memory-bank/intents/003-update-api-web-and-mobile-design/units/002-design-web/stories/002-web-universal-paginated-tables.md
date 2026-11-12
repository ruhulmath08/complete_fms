---
id: 002-web-universal-paginated-tables
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 025-design-web
implemented: false
---

# Story: 002-web-universal-paginated-tables

## User Story

**As a** farm owner
**I want** all display data shown as paginated tables like Milk production
**So that** lists and histories are consistent and usable at scale

## Acceptance Criteria

- [ ] **Given** cows, poultry, crops, inventory, and income/expenses list pages, **When** I view them, **Then** data is in Milk-style tables with pagination (default page size 10)
- [ ] **Given** more than 10 rows, **When** I paginate, **Then** I can reach later pages (no silent cap at 100 without controls)
- [ ] **Given** a shared page/list layout, **When** developers add a list, **Then** they compose the shared pattern rather than copying a full page
- [ ] **Given** milk/feeding histories, **When** viewed, **Then** they retain paginated table behavior

## Technical Notes

- Depends on API list meta from `001-design-api` for accurate totals; may ship UI against existing meta where already present

## Dependencies

### Requires

- 003-api-entity-list-pagination-parity (for full parity)

### Enables

- Totals and Action column stories

## Edge Cases

| Scenario   | Expected Behavior        |
| ---------- | ------------------------ |
| Empty list | Empty state (FR-5 story) |

## Out of Scope

- Action/Total columns (separate story)
