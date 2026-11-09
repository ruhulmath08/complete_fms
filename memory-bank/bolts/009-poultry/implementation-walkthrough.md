---
stage: implement
bolt: 009-poultry
created: 2026-11-09T11:54:11Z
---

# Implementation Walkthrough: Poultry (Mobile)

## Summary

Extended the Flutter app with poultry group list/create/detail workflows including feeding and eggs, EN+BN strings, wired through the shared Dio `ApiClient`.

## Structure Overview

Domain entities and use cases for poultry; data layer API + repository; presentation pages under `presentation/poultry`. Router and shell expose poultry entry points alongside cows.

## Completed Work

- [x] `mobile/lib/domain/entities/poultry.dart` — group/egg/feeding entities and write params
- [x] `mobile/lib/domain/repositories/poultry_repository.dart` — repository port
- [x] `mobile/lib/domain/usecases/poultry_usecases.dart` — poultry use cases
- [x] `mobile/lib/data/datasources/poultry_api.dart` — poultry HTTP calls
- [x] `mobile/lib/data/mappers/poultry_mappers.dart` — JSON mapping
- [x] `mobile/lib/data/repositories/poultry_repository_impl.dart` — repository impl
- [x] `mobile/lib/presentation/poultry/pages/poultry_list_page.dart` — list + archived toggle
- [x] `mobile/lib/presentation/poultry/pages/poultry_create_page.dart` — create form
- [x] `mobile/lib/presentation/poultry/pages/poultry_detail_page.dart` — edit/archive/eggs/feeding
- [x] `mobile/lib/presentation/poultry/widgets/poultry_group_form_fields.dart` — shared form fields
- [x] DI, router (`/poultry`), shell, home entry
- [x] `app_en.arb` / `app_bn.arb` — localized poultry strings
- [x] Mapper + l10n critical-path tests

## Key Decisions

- **Reuse `AcquisitionSource` / `PagedResult`** from cows entities via export
- **StatefulWidget pages**: match cows/auth pattern for v1
- **Hide egg UI for broiler**; archive confirm mirrors web (ADR-004)

## Deviations from Plan

None material.

## Dependencies Added

None.

## Developer Notes

- `flutter analyze` clean after unused-show fix; suite 19/19 passed
- Requires backend poultry migration and signed-in session for manual verification
