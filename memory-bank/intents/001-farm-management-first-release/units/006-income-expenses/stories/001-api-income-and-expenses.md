---
id: 001-api-income-and-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 016-income-expenses
implemented: false
---

# Story: 001-api-income-and-expenses

## User Story

**As a** farm owner
**I want** to record general income and expenses and see period totals
**So that** I can track non-crop farm money simply

## Acceptance Criteria

- [ ] Given I am signed in, When I CRUD/archive income/expense entries, Then they persist for my farm
- [ ] Given a date range, When I request totals, Then total income and total expenses are correct
- [ ] Given crop expenses belong in crops module, When using general ledger, Then crop expenses are not double-counted here

## Technical Notes

amount vs total_price semantics TBD in Construction.

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
