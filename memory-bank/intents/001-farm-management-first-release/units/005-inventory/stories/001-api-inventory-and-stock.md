---
id: 001-api-inventory-and-stock
unit: 005-inventory
intent: 001-farm-management-first-release
status: complete
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 013-inventory
implemented: true
---

# Story: 001-api-inventory-and-stock

## User Story

**As a** farm owner
**I want** to manage inventory items and stock updates
**So that** quantities stay accurate and never go negative

## Acceptance Criteria

- [x] Given I am signed in, When I CRUD/archive items, Then they persist for my farm
- [x] Given a stock add/use update, When applied, Then displayed quantity reflects updates
- [x] Given an update that would go below zero, When submitted, Then it is rejected with a stable error code

## Technical Notes

`total_price` is computed on read as quantity × price_per_unit (not stored).

## Dependencies

### Requires
- Prior stories in this unit's API→web→mobile order as applicable; unit depends on `001-platform-and-auth` for domain units

### Enables
- Subsequent stories in this unit and client bolts for the same slice

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Unauthorized access | Reject with consistent API error |
| Validation failure | Stable `code` + user-facing `message` |

## Out of Scope

- Multi-farm / staff roles / advanced accounting / forecasting
