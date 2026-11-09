---
id: 003-api-owner-signin-signout
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 001-platform-and-auth
implemented: false
---

# Story: 003-api-owner-signin-signout

## User Story

**As a** farm owner
**I want** to sign in with email/password and sign out
**So that** only I can access my private farm data

## Acceptance Criteria

- [ ] Given valid credentials, When I sign in, Then I receive access and refresh JWTs usable by web and mobile
- [ ] Given invalid credentials, When I sign in, Then I am rejected without exposing secrets
- [ ] Given I am signed in, When I sign out / refresh is rotated-revoked per rules, Then private routes reject the old access context

## Technical Notes

Short access TTL + refresh rotation/reuse detection; exact TTLs TBD.

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
