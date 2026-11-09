---
id: 005-web-auth-and-settings
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 002-platform-and-auth
implemented: false
---

# Story: 005-web-auth-and-settings

## User Story

**As a** farm owner
**I want** to sign up, sign in, sign out, and manage profile/settings in the React app
**So that** I can use the system from the browser against the same API rules

## Acceptance Criteria

- [ ] Given the API auth endpoints exist, When I complete signup/signin on web, Then tokens are stored securely for subsequent calls
- [ ] Given validation or API errors, When they occur, Then the web UI shows the API `message` and can branch on `code`
- [ ] Given I am signed in, When I edit profile/settings, Then web reflects saved values from the API

## Technical Notes

Document OpenAPI/contract before wiring screens. Shared tokens CSS variables.

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
