---
stage: implement
bolt: 006-cows
created: 2026-11-09T11:13:39Z
---

# Implementation Walkthrough: Cows (Mobile)

## Summary

Extended the Flutter app with cow list/create/detail workflows including milk and feeding, EN+BN strings, and a shared Dio `ApiClient` so auth and cows share Bearer refresh handling.

## Structure Overview

Domain entities and use cases for cows; data layer API + repository; presentation pages under `presentation/cows`. Router and shell expose cows entry points. Auth DI now registers `ApiClient` used by both `AuthApi` and `CowsApi`.

## Completed Work

- [x] `mobile/lib/data/datasources/api_client.dart` — shared Dio client with refresh interceptor
- [x] `mobile/lib/data/datasources/auth_api.dart` — refactored onto ApiClient
- [x] `mobile/lib/data/datasources/cows_api.dart` — cows/milk/feeding HTTP calls
- [x] `mobile/lib/domain/entities/cow.dart` — cow/milk/feeding entities and write params
- [x] `mobile/lib/domain/repositories/cows_repository.dart` — repository port
- [x] `mobile/lib/domain/usecases/cows_usecases.dart` — cows use cases
- [x] `mobile/lib/data/mappers/cows_mappers.dart` — JSON mapping
- [x] `mobile/lib/data/repositories/cows_repository_impl.dart` — repository impl
- [x] `mobile/lib/presentation/cows/pages/cows_list_page.dart` — list + archived toggle
- [x] `mobile/lib/presentation/cows/pages/cow_create_page.dart` — create form
- [x] `mobile/lib/presentation/cows/pages/cow_detail_page.dart` — edit/archive/milk/feeding
- [x] `mobile/lib/presentation/cows/widgets/cow_form_fields.dart` — shared form fields
- [x] `mobile/lib/infrastructure/di/injection.dart` — register cows deps
- [x] `mobile/lib/infrastructure/router/app_router.dart` — `/cows` routes
- [x] `mobile/lib/presentation/shell/app_shell.dart` / `home_page.dart` — navigation entry
- [x] `mobile/lib/l10n/app_en.arb` / `app_bn.arb` — localized cow strings

## Key Decisions

- **Shared ApiClient**: avoid duplicate Dio interceptors for domain modules
- **StatefulWidget pages**: match existing auth settings pattern for v1 speed
- **Archive confirm dialog**: mirrors web confirm behavior (ADR-004)

## Deviations from Plan

None material. Dedicated cows unit tests deferred to Stage 3.

## Dependencies Added

None.

## Developer Notes

- `flutter analyze` clean; existing suite 7/7 passed after AuthApi constructor change
- Requires backend cows migration and signed-in session for manual verification
