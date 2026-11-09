---
stage: implement
bolt: 015-inventory
created: 2026-11-09T13:10:31Z
---

# Implementation Walkthrough: Inventory (Mobile)

## Summary

Added inventory management to the Flutter app: list/create/edit/archive items and record/review stock add/use updates under the authenticated shell, with English and Bangla strings, mirroring crops Clean Architecture patterns and the web inventory IA from bolt `014-inventory`.

## Structure Overview

Domain entities/repository/use cases → Dio API + mappers + repository impl → StatefulWidget pages under `presentation/inventory`. Items list is the primary hub; detail hosts stock updates. DI registers inventory API/repo/use cases; GoRouter, home CTA, and shell nav link to Inventory.

## Completed Work

- [x] `lib/domain/entities/inventory.dart` — item, stock update, categories, write params
- [x] `lib/domain/repositories/inventory_repository.dart` + `lib/domain/usecases/inventory_usecases.dart`
- [x] `lib/data/datasources/inventory_api.dart`, `mappers/inventory_mappers.dart`, `repositories/inventory_repository_impl.dart`
- [x] Pages: list (include-archived), create, detail (edit/archive + stock updates); form field widgets
- [x] DI, GoRouter routes, home CTA, shell nav
- [x] ARB EN+BN inventory keys; `flutter gen-l10n`
- [x] Tests: `inventory_mappers_test.dart`, `inventory_l10n_test.dart` (full suite 27/27)

## Key Decisions

- **Quantity only on create**; later changes via stock updates (matches API/web)
- **Archive write-block** in UI (ADR-004); surface `INSUFFICIENT_STOCK` via failure message
- **Show `total_price`** from API on list and detail
- **Routes** `/inventory`, `/inventory/new`, `/inventory/:itemId` aligned with web

## Deviations from Plan

None material. Stage 3 test walkthrough still pending.

## Dependencies Added

None.

## Developer Notes

- Requires backend with inventory migration applied and owner signed in
- `flutter test` and `flutter analyze` (inventory paths) verified after implementation
