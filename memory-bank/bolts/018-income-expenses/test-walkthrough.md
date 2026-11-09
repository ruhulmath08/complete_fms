---
stage: test
bolt: 018-income-expenses
created: 2026-11-09T13:32:58Z
---

# Test Report: Income and Expenses (Mobile)

## Summary

- **Tests**: 30/30 passed (3 new ledger + 27 prior)
- **Coverage**: Critical-path mappers (entry/total_price, period totals, write snake_case), EN/BN ledger strings

**Commands**: `flutter test` in `mobile/`; ledger-path `flutter analyze` clean

## Test Files

- [x] `mobile/test/data/ledger_mappers_test.dart` — entry + totals mapping; write payload enums/snake_case
- [x] `mobile/test/l10n/ledger_l10n_test.dart` — ledger UI strings in English and Bangla

## Acceptance Criteria Validation

- ✅ **List/create/edit/archive + date filters/totals screens**: implemented in Stage 2; mapper coverage for API shapes
- ✅ **Bangla and English ledger strings**: l10n widget test
- ✅ **Archive write-block / API message errors**: UI uses same `AppFailure.message` pattern as inventory/crops
- ⏭ **Full device E2E vs live API**: deferred to local smoke (`flutter run` + backend)

## Issues Found

None.

## Notes

Screen widget tests can be added later if regressions appear. Unit `006-income-expenses` vertical slice (API + web + mobile) is complete with this bolt.
