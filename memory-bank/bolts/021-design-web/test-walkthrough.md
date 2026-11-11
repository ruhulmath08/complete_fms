---
stage: test
bolt: 021-design-web
created: 2026-11-11T18:30:50Z
---

# Test Report: Design Web (Cow form + Tables)

## Summary

- **Tests**: 28/28 passed (updated cows form/list/create + prior suite)
- **Coverage**: Critical-path focus for cows refresh

**Commands**: `npm test` in `web/`

## Test Files

- [x] `web/src/features/cows/components/CowForm.test.tsx` — Weight (kg), cow image, no create tag, required name/breed submit
- [x] `web/src/features/cows/pages/CowCreatePage.test.tsx` — API error banner on create failure
- [x] `web/src/features/cows/pages/CowsListPage.test.tsx` — table render with tag link

## Acceptance Criteria Validation

- ✅ Create without client tag; name/breed required; Weight (kg); image control
- ✅ Cows list as table
- ✅ Milk/feeding tables with page size 10 + pagination (implemented; pagination UI covered by component usage — full detail E2E deferred)
- ✅ Critical-path Vitest passes
- ⏭ Live browser E2E against API: deferred to manual/local

## Issues Found

None for this bolt.

## Notes

Mobile parity remains bolts `022` / `023`.
