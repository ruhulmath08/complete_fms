---
stage: implement
bolt: 018-income-expenses
created: 2026-11-09T13:32:02Z
---

# Implementation Walkthrough: Income and Expenses (Mobile)

## Summary

Added general ledger management to the Flutter app: list/create/edit/archive entries with date-range filters and period totals under the authenticated shell, with English and Bangla strings, mirroring inventory Clean Architecture patterns and the web ledger IA from bolt `017-income-expenses`.

## Structure Overview

Domain entities/repository/use cases → Dio API + mappers + repository impl → StatefulWidget pages under `presentation/ledger`. List hosts filters and totals. DI registers ledger API/repo/use cases; GoRouter, home CTA, and shell nav link to Income & expenses.

## Completed Work

- [x] `lib/domain/entities/ledger.dart` — entry, period totals, write params, enums
- [x] `lib/domain/repositories/ledger_repository.dart` + `lib/domain/usecases/ledger_usecases.dart`
- [x] `lib/data/datasources/ledger_api.dart`, `mappers/ledger_mappers.dart`, `repositories/ledger_repository_impl.dart`
- [x] Pages: list (filters + totals), create, detail (edit/archive); form field widgets
- [x] DI, GoRouter routes, home CTA, shell nav
- [x] ARB EN+BN ledger keys; `flutter gen-l10n`
- [x] Tests: `ledger_mappers_test.dart`, `ledger_l10n_test.dart` (full suite 30/30)

## Key Decisions

- **Routes** `/ledger`, `/ledger/new`, `/ledger/:entryId` aligned with web
- **Default date range** = current calendar month for list + totals
- **Archive write-block** in UI (ADR-004); crop guidance copy on list/create

## Deviations from Plan

None material. Stage 3 test walkthrough still pending.

## Dependencies Added

None.

## Developer Notes

- Requires backend with ledger migration applied and owner signed in
- `flutter test` and `flutter analyze` (ledger paths) verified after implementation
