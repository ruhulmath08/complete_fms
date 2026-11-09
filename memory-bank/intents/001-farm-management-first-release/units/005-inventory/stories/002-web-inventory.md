---
id: 002-web-inventory
unit: 005-inventory
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 014-inventory
implemented: false
---

# Story: 002-web-inventory

## User Story

**As a** farm owner
**I want** to manage inventory on web
**So that** I can track supplies in the browser

## Acceptance Criteria

- [ ] Given inventory API exists, When I use web, Then items and stock updates work including below-zero prevention messaging

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
