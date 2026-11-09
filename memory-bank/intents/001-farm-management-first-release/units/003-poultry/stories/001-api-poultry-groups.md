---
id: 001-api-poultry-groups
unit: 003-poultry
intent: 001-farm-management-first-release
status: complete
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 007-poultry
implemented: true
---

# Story: 001-api-poultry-groups

## User Story

**As a** farm owner
**I want** to manage poultry groups and bird counts
**So that** I can track broilers, ducks, layers, and local birds

## Acceptance Criteria

- [x] Given I am signed in, When I CRUD/archive a poultry group, Then data persists for my farm only
- [x] Given birds are added or removed, When I update bird count, Then the new count is stored
- [x] Given purchased acquisition, When purchase fields are set, Then they apply only for purchased groups

## Technical Notes

Follow project standards and document API contract before client screens for this slice.

## Dependencies

### Requires

- Prior stories in this unit's API→web→mobile order as applicable; unit depends on `001-platform-and-auth` for domain units

### Enables

- Subsequent stories in this unit and client bolts for the same slice

## Edge Cases

| Scenario            | Expected Behavior                     |
| ------------------- | ------------------------------------- |
| Unauthorized access | Reject with consistent API error      |
| Validation failure  | Stable `code` + user-facing `message` |

## Out of Scope

- Multi-farm / staff roles / advanced accounting / forecasting
