---
id: 002-api-cow-milk-and-feeding
unit: 002-cows
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 004-cows
implemented: false
---

# Story: 002-api-cow-milk-and-feeding

## User Story

**As a** farm owner
**I want** to record milk production and feeding and review entries
**So that** I can track production and feed history per cow

## Acceptance Criteria

- [ ] Given a milk or both purpose cow, When I add milk entries, Then they list for that cow
- [ ] Given a meat-only cow, When milk is not recorded, Then the cow remains valid without milk records
- [ ] Given any cow, When I add feeding entries, Then I can review them for that cow

## Technical Notes

Document contract before clients.

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
