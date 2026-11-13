---
unit: 002-ops-calc-web
bolt: 033-ops-calc-web
stage: test
status: complete
updated: '2026-11-13T07:55:00Z'
---

# Test Walkthrough - 033-ops-calc-web

## Summary

| Suite | Passed | Failed |
|-------|--------|--------|
| Vitest full `web/` | 56 | 0 |

**Command**:

```bash
cd web && npm test
# 21 files, 56 passed
```

## Test Files

- [x] `CropCycleDetailPage.test.tsx` — Action, edit PATCH, delete confirm, archived hide
- [x] `InventoryListPage.test.tsx` — fertilizer category query, pagination, empty
- [x] `LedgerListPage.test.tsx` — chart below Apply, series params, clamp
- [x] `DashboardPage.test.tsx` — period default week, six series, max date
- [x] `SignInPage.test.tsx` / `AppShell.test.tsx` — dashboard redirect/nav
- [x] `shared/dates.test.ts` — week bounds / clamp helpers

## Acceptance Criteria Validation

| Story / Criterion | Status |
|-------------------|--------|
| Expense/harvest Edit + Delete with confirm | ✅ |
| Edit primary / Delete danger styling | ✅ |
| Fertilizer-only stock table + empty state | ✅ |
| Ledger numeric totals + graph after Apply | ✅ |
| Login lands on Dashboard; nav entry | ✅ |
| Default this week; future dates blocked | ✅ |
| Six dashboard graph areas | ✅ |

## Issues Found

None blocking. Mobile remains bolt `034`.
