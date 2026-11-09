---
id: 006-mobile-auth-and-settings
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 003-platform-and-auth
implemented: true
---

# Story: 006-mobile-auth-and-settings

## User Story

**As a** farm owner
**I want** to sign up, sign in, sign out, and manage profile/settings in Flutter
**So that** I can use the system on mobile with Bangla and English

## Acceptance Criteria

- [ ] Given the API auth endpoints exist, When I complete signup/signin on mobile, Then tokens are stored and used for API calls to the local API in dev
- [ ] Given API errors, When they occur, Then mobile shows user-facing `message` consistently with web
- [ ] Given locale Bangla or English, When I use auth/settings screens, Then strings are localized

## Technical Notes

Clean Architecture layers; BLoC; domain pure Dart.

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
