---
stage: test
bolt: 006-cows
created: 2026-11-09T11:17:42Z
---

# Test Report: Cows (Mobile)

## Summary

- **Tests**: 13/13 passed (6 new cows + 7 prior)
- **Coverage**: Critical-path mappers, purchase-field serialization, EN/BN cow strings

**Command**: `flutter test` in `mobile/`

## Test Files

- [x] `mobile/test/data/cows_mappers_test.dart` — cow/milk/feeding mapping; milk eligibility; purchase fields on write
- [x] `mobile/test/l10n/cows_l10n_test.dart` — cow UI strings in English and Bangla

## Acceptance Criteria Validation

- ✅ **CRUD/archive + milk/feeding screens**: implemented in Stage 2; mapper coverage for API shapes
- ✅ **Bangla and English cow strings**: l10n widget test
- ✅ **Purchase fields only when purchased**: `cowWriteToJson` clears vs keeps purchase fields
- ✅ **Meat not milk-eligible**: entity/mapper assertion
- ⏭ **Full device E2E vs live API**: deferred to local smoke (`flutter run` + backend)

## Issues Found

None.

## Notes

UI error display reuses `AppFailure.message` (already covered by auth failures tests). Screen widget tests can be added later if regressions appear.
