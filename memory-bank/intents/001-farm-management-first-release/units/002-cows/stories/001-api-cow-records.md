---
id: 001-api-cow-records
unit: 002-cows
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 004-cows
implemented: true
---

# Story: 001-api-cow-records

## User Story

**As a** farm owner
**I want** to add, view, edit, and archive cow records
**So that** I can track each cow for milk and/or meat

## Acceptance Criteria

- [ ] Given I am signed in, When I create/edit a cow with valid fields, Then it is persisted for my farm only
- [ ] Given acquired_by is purchased, When purchase fields are provided, Then they are stored; otherwise purchase fields are not required
- [ ] Given I archive a cow, When I list active cows, Then archived cows are excluded per product rules for active lists

## Technical Notes

Owner-only scoping required on all queries.

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
