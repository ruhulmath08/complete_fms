---
stage: plan
bolt: 031-poultry-actions-mobile
created: "2026-11-12T10:15:00Z"
---

# Implementation Plan: 031-poultry-actions-mobile

## Objective

Flutter poultry detail: Edit/Delete egg and feeding with confirm (bolt `029` APIs); history **No.** / `rowNumber` labeling; primary Edit / danger Delete colors (poultry + cow Action icons); preserve add; BN/EN l10n.

## Stories

- **001-mobile-poultry-egg-feeding-actions**: Mobile Edit/Delete
- **002-mobile-history-no-and-action-colors**: No. + colors

## Deliverables

- `PoultryApi` PATCH/DELETE egg + feeding; repository, use cases, DI registration
- `poultry_detail_page`: DataTable (or equivalent) with `rowNumber`, Action Edit/Delete, edit-into-form, confirm delete; hide/disable when archived / eggs ineligible
- Icon colors: Edit → primary token; Delete → danger/error (poultry + cow milk/feeding)
- l10n: reuse cow strings where possible (`editEntry`, `delete`, `cancelEdit`, `actions`, `rowNumber`); add egg/feeding delete confirms + update labels if missing
- Tests: API/mapper or use-case smoke; l10n EN/BN for new strings; critical UI/widget where practical
- Verify: `flutter gen-l10n`, `flutter test`

## Dependencies

- **029-poultry-actions-api** (complete)
- Pattern reference: `cow_detail_page` milk/feeding Action (bolt `028`)

## Technical Approach

1. Mirror cows data stack: `updateEgg`/`deleteEgg`/`updateFeeding`/`deleteFeeding` on API → repository → use cases → `injection.dart`
2. Refactor poultry egg/feeding UI toward cow DataTable + form edit mode (`_editingEggId` / `_editingFeedingId`)
3. Apply `IconButton` `color:` from `AppTokens` / `ColorScheme` for primary edit and danger delete on poultry and cow histories
4. Ensure no `#` row-index labels remain on mobile history tables
5. Add/adjust arb strings; regenerate l10n; extend tests

## Acceptance Criteria

- [ ] Owner can add/edit/delete egg and feeding on poultry detail via API
- [ ] Delete confirms; Cancel keeps row; archived/non-eligible mutations hidden/disabled
- [ ] History index uses **No.** / `rowNumber` (BN equivalent)
- [ ] Edit primary / Delete danger on poultry and cow Action icons
- [ ] EN + BN strings resolve; `flutter test` green

## Out of Scope

- Web UI; soft-delete; poultry feeding `unit_cost`; rebuilding shell/nav
