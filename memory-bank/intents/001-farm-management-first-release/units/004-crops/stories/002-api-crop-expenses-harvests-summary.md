---
id: 002-api-crop-expenses-harvests-summary
unit: 004-crops
intent: 001-farm-management-first-release
status: complete
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 010-crops
implemented: true
---

# Story: 002-api-crop-expenses-harvests-summary

## User Story

**As a** farm owner
**I want** to record crop expenses and harvests and see a simple summary
**So that** I understand entered crop costs vs sale income

## Acceptance Criteria

- [x] Given a crop cycle, When I add categorized expenses, Then they are listed for that cycle
- [x] Given a harvest with optional sale amount, When recorded, Then it appears on the cycle
- [x] Given expenses and sale income, When I fetch summary, Then totals and income-minus-expenses match entered records

## Technical Notes

Not full accounting; no double-count with general expenses module.

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
