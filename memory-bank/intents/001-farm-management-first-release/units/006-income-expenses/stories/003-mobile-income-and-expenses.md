---
id: 003-mobile-income-and-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
status: complete
priority: must
created: '2026-11-09T06:55:29Z'
assigned_bolt: 018-income-expenses
implemented: true
---

# Story: 003-mobile-income-and-expenses

## User Story

**As a** farm owner
**I want** to manage general income/expenses on mobile
**So that** I can view entries by date and period totals on my phone

## Acceptance Criteria

- [x] Given ledger API exists, When I use mobile, Then entries, date views, and period totals work with localization

## Technical Notes

Follow project standards and document API contract before client screens for this slice.

## Dependencies

### Requires

- Prior stories in this unit's API→web→mobile order as applicable; unit depends on `001-platform-and-auth` for domain units

### Enables

- Subsequent stories in this unit and client bolts for the same slice

## Edge Cases

| Scenario            | Expected Behavior                     |
| ------------------- | ------------------------------------- |
| Unauthorized access | Reject with consistent API error      |
| Validation failure  | Stable `code` + user-facing `message` |

## Out of Scope

- Multi-farm / staff roles / advanced accounting / forecasting
