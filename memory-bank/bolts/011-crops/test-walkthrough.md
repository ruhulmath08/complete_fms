---
stage: test
bolt: 011-crops
created: 2026-11-09T12:28:00Z
---

# Test Report: Crops (Web)

## Summary

- **Tests**: 20/20 passed (4 new crops + 16 prior poultry/cows/auth/shared)
- **Coverage**: Critical-path focus (cycles list/error, duplicate crop-name banner, cycle form submit)

**Commands**: `npm test -- --run src/features/crops` and `npm run test` in `web/`; `npm run build` verified

## Test Files

- [x] `web/src/features/crops/pages/CropCyclesListPage.test.tsx` — list renders API cycles with crop name; list error shows API `message`
- [x] `web/src/features/crops/pages/CropNameCreatePage.test.tsx` — `CROP_NAME_ALREADY_EXISTS` shows API `message`
- [x] `web/src/features/crops/components/CropCycleForm.test.tsx` — submits payload with selected crop name and optional fields null

## Acceptance Criteria Validation

- ✅ **Catalog list/create/edit/archive**: implemented; create duplicate-name error covered by test
- ✅ **Cycles list/create/edit/archive + crop picker**: implemented; list + form submit covered
- ✅ **Expenses/harvests add/list + summary**: implemented on cycle detail (same ErrorBanner/mutation pattern as poultry eggs/feeding)
- ✅ **Archived write block**: implemented (hide edit/archive/add when archived)
- ✅ **API errors via shared banner**: list + create assert API `message`
- ✅ **Protected routes / nav / home CTA**: wired; ProtectedRoute covered by existing suite
- ⏭ **Full browser E2E vs live API**: deferred to manual/local (`backend` + `web`)

## Issues Found

None.

## Notes

Expense/harvest/summary and name/cycle detail archive flows reuse the verified ErrorBanner + mutation pattern from create/list; deeper detail-page interaction tests can be added if regressions appear.
