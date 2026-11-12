---
id: 003-web-crops
unit: 004-crops
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 011-crops
implemented: true
---

# Story: 003-web-crops

## User Story

**As a** farm owner
**I want** to manage crop names, cycles, expenses, harvests, and summary on web
**So that** I can complete crop workflows in the browser

## Acceptance Criteria

- [x] Given crops API exists, When I use web, Then catalog, cycles, expenses, harvests, and summary work

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
