---
stage: implement
bolt: 003-platform-and-auth
created: 2026-11-09T09:56:34Z
---

# Implementation Walkthrough: Platform and Auth (Mobile)

## Summary

Scaffolded a Flutter app under `mobile/` with Clean Architecture folders, BLoC/Cubit session and locale state, GoRouter auth redirects, GetIt DI, Material 3 theming, Dio API client with token refresh, secure token storage, and Bangla/English localization for auth and settings screens.

## Structure Overview

Domain stays pure Dart (entities, repository contract, use cases). Data implements API + secure storage. Presentation hosts screens and cubits. Infrastructure wires DI, router, theme, and API config. ARB files drive EN/BN strings.

## Completed Work

- [x] `mobile/` Flutter scaffold + `pubspec.yaml` / `README.md`
- [x] `mobile/lib/domain/**` — entities, failures, auth repository interface, use cases
- [x] `mobile/lib/data/**` — Dio AuthApi, TokenStore, mappers, AuthRepositoryImpl
- [x] `mobile/lib/presentation/session/session_cubit.dart` — signed-in bootstrap/sign-out
- [x] `mobile/lib/presentation/locale/locale_cubit.dart` — EN/BN toggle
- [x] `mobile/lib/presentation/auth/pages/**` — sign-in, sign-up, home, profile, farm settings
- [x] `mobile/lib/presentation/shell/app_shell.dart` — authenticated chrome
- [x] `mobile/lib/infrastructure/**` — DI, router, theme, API config
- [x] `mobile/lib/l10n/**` — English and Bangla ARB + generated localizations
- [x] `mobile/lib/main.dart` / `app.dart` — bootstrap
- [x] `mobile/ios/Runner/Info.plist` — photo library usage + display name
- [x] `mobile/test/widget_test.dart` — placeholder domain failure test (full suite in Stage 3)

## Key Decisions

- **Single Flutter package with folder layers** for v1 speed; domain still has no Flutter/API imports
- **flutter_secure_storage** for access/refresh tokens
- **Dio interceptor refresh-on-401** matching web/API rotation rules
- **Default API base `http://10.0.2.2:8000`** for Android emulator; overridable via `--dart-define=API_BASE_URL=...`
- **Material 3 + shared green primary** aligned with web tokens
- **LocaleCubit** for explicit Bangla/English switching on home

## Deviations from Plan

Separate pub packages for domain/data were deferred; folder boundaries satisfy the Clean Architecture intent for this bolt without multi-package overhead.

## Dependencies Added

- [x] `flutter_bloc`, `go_router`, `get_it`, `dio`, `flutter_secure_storage`, `image_picker`, `intl`, `equatable`, `flutter_localizations`
- [x] Dev: `bloc_test`, `mocktail`

## Developer Notes

- `flutter analyze` clean; run backend locally before device/emulator smoke tests
- Stage 3 will expand critical-path Flutter tests beyond the initial AppFailure check
