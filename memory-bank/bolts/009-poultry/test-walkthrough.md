---
stage: test
bolt: 009-poultry
created: 2026-11-09T11:55:42Z
---

# Test Report: Poultry (Mobile)

## Summary

- **Tests**: 19/19 passed (6 new poultry + 13 prior)
- **Coverage**: Critical-path mappers, purchase-field serialization, egg eligibility, EN/BN poultry strings

**Command**: `flutter test` in `mobile/`

## Test Files

- [x] `mobile/test/data/poultry_mappers_test.dart` — group/egg/feeding mapping; egg eligibility; purchase fields on write
- [x] `mobile/test/l10n/poultry_l10n_test.dart` — poultry UI strings in English and Bangla

## Acceptance Criteria Validation

- ✅ **CRUD/archive + feeding/eggs screens**: implemented in Stage 2; mapper coverage for API shapes
- ✅ **Bangla and English poultry strings**: l10n widget test
- ✅ **Purchase fields only when purchased**: `poultryGroupWriteToJson` clears vs keeps purchase fields
- ✅ **Broiler not egg-eligible**: entity/mapper assertion
- ⏭ **Full device E2E vs live API**: deferred to local smoke (`flutter run` + backend)

## Issues Found

None.

## Notes

UI error display reuses `AppFailure.message` (already covered by auth failures tests). Screen widget tests can be added later if regressions appear.
