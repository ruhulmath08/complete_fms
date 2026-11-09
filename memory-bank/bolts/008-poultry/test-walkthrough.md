---
stage: test
bolt: 008-poultry
created: 2026-11-09T11:46:01Z
---

# Test Report: Poultry (Web)

## Summary

- **Tests**: 16/16 passed (5 new poultry + 11 prior cows/auth/shared)
- **Coverage**: Critical-path focus (list/error, create error message, purchase-field UX)

**Command**: `npm run test` in `web/`

## Test Files

- [x] `web/src/features/poultry/pages/PoultryListPage.test.tsx` — list renders API groups; list error shows API `message`
- [x] `web/src/features/poultry/pages/PoultryCreatePage.test.tsx` — `PURCHASE_FIELDS_INVALID` shows API `message`
- [x] `web/src/features/poultry/components/PoultryGroupForm.test.tsx` — purchase fields toggle; born-on-farm submit clears purchase fields

## Acceptance Criteria Validation

- ✅ **List/create/edit/archive + feeding/eggs screens**: implemented in Stage 2; list + create covered by tests
- ✅ **API validation errors use shared handling**: create/list error banners assert API `message`
- ✅ **Purchase fields when purchased**: PoultryGroupForm toggle + submit payload test
- ✅ **Broiler omits egg CTA / archive write block**: implemented in detail page (same pattern as cows meat/archive)
- ✅ **Protected routes**: unchanged; still covered by existing ProtectedRoute test
- ⏭ **Full browser E2E vs live API**: deferred to manual/local (`backend` + `web`)

## Issues Found

None.

## Notes

Archive/feeding/egg flows rely on the same ErrorBanner + mutation pattern verified on create; deep detail-page interaction tests can be added later if regressions appear.
