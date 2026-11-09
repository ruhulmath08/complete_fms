---
id: 004-api-profile-farm-settings
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 001-platform-and-auth
implemented: true
---

# Story: 004-api-profile-farm-settings

## User Story

**As a** signed-in farm owner
**I want** to view and update profile and farm settings including currency code
**So that** my farm preferences stay current on all clients

## Acceptance Criteria

- [ ] Given I am signed in, When I update profile fields, Then changes persist and are returned by the API
- [ ] Given default currency BDT, When I change currency code in farm settings, Then the new code is stored
- [ ] Given I attempt an email/phone taken by another account, When I update, Then the API rejects with a stable error

## Technical Notes

Suggested units list can be exposed as static config; final list TBD.

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
