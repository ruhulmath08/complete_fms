---
stage: test
bolt: 022-design-mobile
created: 2026-11-11T18:38:00Z
---

# Test Report: Design Mobile (Cards + Tokens)

## Summary

- **Tests**: full `flutter test` suite passed (includes new EntityListCard + AppTokens cases)
- **Coverage**: critical-path widget tests for shared card and central tokens

**Commands**: `flutter test` in `mobile/`

## Test Files

- [x] `mobile/test/presentation/shared/entity_list_card_test.dart` — title/subtitle render, onTap, primary `#2F6A3A` / border / radius from `AppTokens`

## Acceptance Criteria Validation

- ✅ Domain lists use shared `EntityListCard` (cows, poultry, crop cycles/names, inventory, ledger)
- ✅ Tap wiring preserved to existing detail routes
- ✅ Empty states retain clear centered l10n messaging
- ✅ Tokens defined centrally via `AppTokens` + `cardTheme`; primary green `#2F6A3A`
- ✅ Critical-path widget tests + full suite green
- ⏭ Live device UI walkthrough: deferred to manual

## Issues Found

None for this bolt.

## Notes

Cow create image / Weight (kg) / auto-tag remain bolt `023-design-mobile`.
