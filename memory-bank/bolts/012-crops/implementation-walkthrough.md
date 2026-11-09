---
stage: implement
bolt: 012-crops
created: 2026-11-09T12:35:00Z
---

# Implementation Walkthrough: Crops (Mobile)

## Summary

Added crop management to the Flutter app: catalog (crop names), planting cycles, expenses, harvests, and cycle summary under the authenticated shell, with English and Bangla strings, mirroring poultry/cows Clean Architecture patterns and the web crops IA from bolt `011-crops`.

## Structure Overview

Domain entities/repository/use cases → Dio API + mappers + repository impl → StatefulWidget pages under `presentation/crops`. Cycles list is the primary hub; names live under `/crops/names`. DI registers crops API/repo/use cases; GoRouter, home CTA, and shell nav link to Crops.

## Completed Work

- [x] `lib/domain/entities/crop.dart` — CropName, CropCycle, CropExpense, Harvest, CycleSummary, write params, ExpenseCategory
- [x] `lib/domain/repositories/crops_repository.dart` + `lib/domain/usecases/crops_usecases.dart`
- [x] `lib/data/datasources/crops_api.dart`, `mappers/crops_mappers.dart`, `repositories/crops_repository_impl.dart`
- [x] Pages: cycles list/create/detail; names list/create/detail; form field widgets
- [x] DI, GoRouter routes, home CTA, shell nav
- [x] ARB EN+BN crops keys; `flutter gen-l10n`
- [x] Tests: `crops_mappers_test.dart`, `crops_l10n_test.dart` (full suite 24/24)

## Key Decisions

- **Cycles as primary hub** at `/crops`; names nested under `/crops/names`
- **Archive write-block** in UI (ADR-004); duplicate active name surfaces API `message` (ADR-007)
- **Active-only picker** for new cycles; edit may keep current name in options
- **Expense category** mapped to/from API snake_case (`pesticides_and_chemicals`)

## Deviations from Plan

None material. Broader Stage 3 test walkthrough still pending.

## Dependencies Added

None.

## Developer Notes

- Requires backend with crops migration applied and owner signed in
- `flutter test` and `flutter analyze` (crops paths) verified after implementation
