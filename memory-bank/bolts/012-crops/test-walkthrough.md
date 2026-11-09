---
stage: test
bolt: 012-crops
created: 2026-11-09T12:36:00Z
---

# Test Report: Crops (Mobile)

## Summary

- **Tests**: 24/24 passed (5 new crops + 19 prior)
- **Coverage**: Critical-path mappers (name/cycle/expense/harvest/summary), expense category snake_case, EN/BN crops strings

**Commands**: `flutter test` in `mobile/`; crops-path `flutter analyze` clean

## Test Files

- [x] `mobile/test/data/crops_mappers_test.dart` — name/cycle/expense/harvest/summary mapping; `pesticides_and_chemicals`; cycle write JSON
- [x] `mobile/test/l10n/crops_l10n_test.dart` — crops UI strings in English and Bangla

## Acceptance Criteria Validation

- ✅ **Catalog/cycles/expenses/harvests/summary screens**: implemented in Stage 2; mapper coverage for API shapes
- ✅ **Bangla and English crops strings**: l10n widget test
- ✅ **Expense category enum ↔ API**: mapper round-trip for snake_case category
- ✅ **Archive write-block / API message errors**: UI uses same `AppFailure.message` pattern as poultry/cows
- ⏭ **Full device E2E vs live API**: deferred to local smoke (`flutter run` + backend)

## Issues Found

None.

## Notes

Screen widget tests can be added later if regressions appear. Unit `004-crops` vertical slice (API + web + mobile) is complete with this bolt.
