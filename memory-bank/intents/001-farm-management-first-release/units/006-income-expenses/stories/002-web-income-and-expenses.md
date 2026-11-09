---
id: 002-web-income-and-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 017-income-expenses
implemented: false
---

# Story: 002-web-income-and-expenses

## User Story

**As a** farm owner
**I want** to manage general income/expenses on web
**So that** I can view entries by date and period totals in the browser

## Acceptance Criteria

- [ ] Given ledger API exists, When I use web, Then entries, date views, and period totals work

## Technical Notes

Follow project standards and document API contract before client screens for this slice.

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
