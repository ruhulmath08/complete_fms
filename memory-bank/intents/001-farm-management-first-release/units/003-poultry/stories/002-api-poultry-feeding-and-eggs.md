---
id: 002-api-poultry-feeding-and-eggs
unit: 003-poultry
intent: 001-farm-management-first-release
status: complete
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 007-poultry
implemented: true
---

# Story: 002-api-poultry-feeding-and-eggs

## User Story

**As a** farm owner
**I want** to record poultry feeding and egg production where applicable
**So that** I can track feed and eggs per group

## Acceptance Criteria

- [x] Given any poultry group, When I record feeding, Then I can review feeding entries
- [x] Given layer, duck, or local, When I record eggs, Then entries are stored and listable
- [x] Given a broiler group, When egg production is omitted, Then the group remains valid

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
