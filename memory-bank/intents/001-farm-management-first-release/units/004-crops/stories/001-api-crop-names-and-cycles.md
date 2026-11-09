---
id: 001-api-crop-names-and-cycles
unit: 004-crops
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 010-crops
implemented: false
---

# Story: 001-api-crop-names-and-cycles

## User Story

**As a** farm owner
**I want** to manage crop names and crop cycles
**So that** cycles always reference a managed crop name

## Acceptance Criteria

- [ ] Given I am signed in, When I CRUD/archive crop names, Then the catalog updates
- [ ] Given I create a crop cycle, When crop name is not from the catalog, Then the API rejects it
- [ ] Given valid cycle fields, When I CRUD/archive cycles, Then they persist for my farm

## Technical Notes

Follow project standards and document API contract before client screens for this slice.

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
