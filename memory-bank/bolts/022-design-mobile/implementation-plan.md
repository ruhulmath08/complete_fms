---
stage: plan
bolt: 022-design-mobile
created: 2026-11-11T18:32:30Z
---

# Implementation Plan: Design Mobile (Cards + Tokens)

## Objective

Refresh Flutter domain list screens to use a shared card-style list item, and centralize brand/spacing tokens (primary `#2f6a3a` and web-aligned neutrals) so list chrome is consistent without scattering magic numbers.

## Stories in Scope

- **001-mobile-list-cards**: Card layouts for cows, poultry, crops (cycles + names), inventory, ledger lists; tap → existing detail; clear empty state
- **002-mobile-design-tokens**: Central tokens (primary green + related colors/radius/spacing); apply to cards/theme

## Deliverables

1. Shared list card widget (e.g. `presentation/shared/widgets/entity_list_card.dart` or under `infrastructure/theme/`) with title, optional subtitle, `onTap`, and token-driven border/radius/padding
2. Replace bordered `ListTile` rows in:
   - `cows_list_page.dart`
   - `poultry_list_page.dart`
   - `crop_cycles_list_page.dart`
   - `crop_names_list_page.dart`
   - `inventory_list_page.dart`
   - `ledger_list_page.dart`
3. Extend `AppTheme` / theme tokens toward web CSS parity where practical:
   - Keep `primary` `#2F6A3A`
   - Add muted, border, surface, radius, spacing constants (or `ThemeExtension`)
   - Wire `cardTheme` / list card to those tokens
4. Keep existing empty-state copy clear (centered `no*` l10n); no illustrated empty UI required
5. Widget test for the shared card (tap + title/subtitle); run existing mobile test suite

## Dependencies

1. Existing list pages + GoRouter detail routes (no API changes)
2. Web tokens in `web/src/index.css` as parity reference only
3. Bolt `023` owns cow form image / Weight (kg) / auto-tag — out of this bolt

## Technical Approach

1. **Tokens first**: Expand `mobile/lib/infrastructure/theme/app_theme.dart` with named colors/spacing/radius aligned to web (`muted`, `border`, `surface`, radius 12, etc.); optionally a small `AppTokens` / `ThemeExtension`
2. **Shared card**: Material `Card` (or `InkWell` + decorated surface) using theme tokens; ellipsis for long titles
3. **Migrate lists**: Swap each `ListTile` + border for the shared card; preserve titles/subtitles/onTap and `RefreshIndicator` loaders
4. **Theme**: Prefer `Theme.of(context)` / extension over hard-coded colors in list UIs
5. **Tests**: `testWidgets` for shared card; `flutter test` for full suite

## Out of Scope

- Cow create image / Weight (kg) / auto-tag (`023-design-mobile`)
- Cloning web left sidebar onto mobile
- Real notification system
- Full illustrated empty states
- Web SPA changes

## Acceptance Criteria

- [ ] Domain lists (cows, poultry, crops cycles/names, inventory, ledger) render items as cards via a shared widget
- [ ] Tap navigates to existing detail/create flow
- [ ] Empty lists show existing clear empty messaging
- [ ] Primary `#2f6a3a` (and related neutrals/radius) defined centrally and used by cards/theme
- [ ] Critical-path widget test for shared card + full `flutter test` green

## Relevant Prior Decisions

- Intent `002` FR-2 / FR-9; mobile layouts need not match web sidebar
- `AppTheme.primary` already `#2F6A3A` — extend rather than re-seed
- Current lists already use bordered `ListTile` — upgrade to true cards + shared abstraction
