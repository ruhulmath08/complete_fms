---
id: 004-mobile-poultry
unit: 003-poultry
intent: 001-farm-management-first-release
status: complete
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 009-poultry
implemented: true
---

# Story: 004-mobile-poultry

## User Story

**As a** farm owner
**I want** to manage poultry workflows on mobile
**So that** I can complete poultry record keeping on my phone

## Acceptance Criteria

- [x] Given poultry API exists, When I use mobile, Then groups, counts, feeding, and applicable eggs work end-to-end with localization

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
