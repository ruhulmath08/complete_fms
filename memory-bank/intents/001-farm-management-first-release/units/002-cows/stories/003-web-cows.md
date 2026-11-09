---
id: 003-web-cows
unit: 002-cows
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 005-cows
implemented: true
---

# Story: 003-web-cows

## User Story

**As a** farm owner
**I want** to manage cows, milk, and feeding in the web app
**So that** I can complete cow workflows in the browser

## Acceptance Criteria

- [ ] Given cow API exists, When I use web screens, Then I can CRUD/archive cows and record/review milk and feeding
- [ ] Given API validation errors, When shown, Then web uses shared error handling

## Technical Notes

Feature folder under web; TanStack Query.

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
