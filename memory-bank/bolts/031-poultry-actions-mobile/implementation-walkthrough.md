---
stage: implement
bolt: 031-poultry-actions-mobile
created: "2026-11-12T10:25:00Z"
---

# Implementation Walkthrough: 031-poultry-actions-mobile

## Summary

Wired Flutter poultry egg and feeding Edit/Delete against bolt `029` APIs, upgraded poultry history UI to DataTables with **No.** / Actions, and applied primary/danger icon colors on poultry and cow history actions with BN/EN strings.

## Structure Overview

Data stack mirrors cows: API PATCH/DELETE → repository → use cases → DI. Poultry detail now uses the same edit-into-form and confirm-delete pattern as cow milk/feeding, with `AppTokens` colors on Action icons.

## Completed Work

- [x] `mobile/lib/data/datasources/poultry_api.dart` - Egg/feeding PATCH/DELETE
- [x] `mobile/lib/domain/repositories/poultry_repository.dart` - Mutation contracts
- [x] `mobile/lib/data/repositories/poultry_repository_impl.dart` - Repository wiring
- [x] `mobile/lib/domain/usecases/poultry_usecases.dart` - Update/Delete use cases
- [x] `mobile/lib/infrastructure/di/injection.dart` - DI registration
- [x] `mobile/lib/presentation/poultry/pages/poultry_detail_page.dart` - DataTable Action UI
- [x] `mobile/lib/presentation/cows/pages/cow_detail_page.dart` - Primary/danger Action colors
- [x] `mobile/lib/l10n/app_en.arb` / `app_bn.arb` - Egg update/delete strings
- [x] `mobile/test/l10n/poultry_l10n_test.dart` - New string assertions

## Key Decisions

- **Reuse cow UX**: DataTable + shared form for add/update; dialog confirm on delete
- **Color via AppTokens**: Edit `primary`, Delete `danger` on poultry and cow icons
- **Reuse feeding delete string**: Poultry feeding delete uses existing `deleteFeedingConfirm`

## Deviations from Plan

None material

## Dependencies Added

None

## Developer Notes

- `flutter gen-l10n` + `flutter test` (39 passed) run during implement; Stage 3 formalizes the report
