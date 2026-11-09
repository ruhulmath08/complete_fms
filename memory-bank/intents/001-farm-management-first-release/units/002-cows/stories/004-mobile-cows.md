---
id: 004-mobile-cows
unit: 002-cows
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 006-cows
implemented: false
---

# Story: 004-mobile-cows

## User Story

**As a** farm owner
**I want** to manage cows, milk, and feeding in the mobile app
**So that** I can complete cow workflows on my phone

## Acceptance Criteria

- [ ] Given cow API exists, When I use mobile screens, Then I can CRUD/archive cows and record/review milk and feeding
- [ ] Given Bangla or English, When I use cow screens, Then UI strings are localized

## Technical Notes

BLoC + repository against API.

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
