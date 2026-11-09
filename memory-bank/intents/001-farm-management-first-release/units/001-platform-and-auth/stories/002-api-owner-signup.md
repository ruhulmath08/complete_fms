---
id: 002-api-owner-signup
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 001-platform-and-auth
implemented: false
---

# Story: 002-api-owner-signup

## User Story

**As a** new farm owner
**I want** to create an account with required profile fields and password rules
**So that** I can access the farm system securely

## Acceptance Criteria

- [ ] Given valid unique signup data including profile image, When I submit, Then my account is created and password is stored hashed only
- [ ] Given duplicate email or phone, When I submit, Then signup is rejected with a stable error code
- [ ] Given password <8 chars or missing letter/number or confirm mismatch, When I submit, Then validation fails

## Technical Notes

Local disk upload outside Git; exact folder TBD (open question).

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
