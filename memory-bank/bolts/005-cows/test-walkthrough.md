---
stage: test
bolt: 005-cows
created: 2026-11-09T11:10:47Z
---

# Test Report: Cows (Web)

## Summary

- **Tests**: 11/11 passed (5 new cows + 6 prior auth/shared)
- **Coverage**: Critical-path focus (list/error, create error message, purchase-field UX)

**Command**: `npm run test` in `web/`

## Test Files

- [x] `web/src/features/cows/pages/CowsListPage.test.tsx` — list renders API cows; list error shows API `message`
- [x] `web/src/features/cows/pages/CowCreatePage.test.tsx` — `TAG_ALREADY_EXISTS` shows API `message`
- [x] `web/src/features/cows/components/CowForm.test.tsx` — purchase fields toggle; born-on-farm submit clears purchase fields

## Acceptance Criteria Validation

- ✅ **List/create/edit/archive + milk/feeding screens**: implemented in Stage 2; list + create covered by tests
- ✅ **API validation errors use shared handling**: create/list error banners assert API `message`
- ✅ **Purchase fields when purchased**: CowForm toggle + submit payload test
- ✅ **Protected routes**: unchanged; still covered by existing ProtectedRoute test
- ⏭ **Full browser E2E vs live API**: deferred to manual/local (`backend` + `web`)

## Issues Found

None.

## Notes

Archive/milk/feeding flows rely on the same ErrorBanner + mutation pattern verified on create; deep detail-page interaction tests can be added later if regressions appear.
