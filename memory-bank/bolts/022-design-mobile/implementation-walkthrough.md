---
stage: implement
bolt: 022-design-mobile
created: 2026-11-11T18:35:00Z
---

# Implementation Walkthrough: Design Mobile (Cards + Tokens)

## What Changed

1. **`AppTokens` ThemeExtension** in `mobile/lib/infrastructure/theme/app_theme.dart`
   - Central primary `#2F6A3A`, muted/border/surface/ink, radius, spacing
   - Registered on `ThemeData`; `cardTheme` uses surface + border + radius
2. **`EntityListCard`** at `mobile/lib/presentation/shared/widgets/entity_list_card.dart`
   - Title/subtitle with ellipsis; token-driven padding/colors; `Card` + `InkWell`
3. **List screens** migrated from bordered `ListTile` to `EntityListCard`:
   - cows, poultry, crop cycles, crop names, inventory, ledger
4. **Tests**: `test/presentation/shared/entity_list_card_test.dart` (tap + token values)

## Stories Covered

- 001-mobile-list-cards
- 002-mobile-design-tokens

## Notes

- Empty states unchanged (centered l10n `no*` text)
- Cow form image / Weight (kg) / auto-tag remain bolt `023`
