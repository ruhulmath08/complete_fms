---
stage: plan
bolt: 003-platform-and-auth
created: 2026-11-09T09:51:11Z
---

# Implementation Plan: Platform and Auth (Mobile)

## Objective

Scaffold the Flutter app and deliver owner signup, sign-in, sign-out, profile, and farm settings against the shared `/api/v1` auth contract, with Bangla and English localization and Clean Architecture layering.

## Story in Scope

- **006-mobile-auth-and-settings**: Mobile auth/settings with localized strings

## Deliverables

1. Flutter app under `mobile/` using Clean Architecture, BLoC, GoRouter, GetIt, Material 3
2. Layering aligned with standards:
   - `presentation/` — screens, widgets, BLoCs
   - `domain/` — pure Dart entities, use cases, repository interfaces (no Flutter/API imports)
   - `data/` — API client, models, mappers, repository implementations
   - `infrastructure/` — theme, localization, DI, router, secure storage
3. Auth flows: signup (multipart + profile image), sign-in, sign-out, profile view/edit, farm settings (currency)
4. Token persistence for local API calls in development (secure storage preferred)
5. Refresh-on-401 with rotation; clear session on reuse/invalid refresh
6. User-facing API `message` display consistent with web; branch on `code` where useful
7. l10n for Bangla (`bn`) and English (`en`) on auth/settings strings
8. Critical-path Flutter tests (domain/BLoC focused)

## Dependencies

1. **`001-platform-and-auth` (API)** — complete
2. **`002-platform-and-auth` (Web)** — complete (contract + UX parity reference)
3. **API endpoints** — same as web bolt (`/auth/*`, `/me`, `/farm-settings`)
4. **Packages (planned)**: `flutter_bloc`, `go_router`, `get_it`, `dio` (or `http`), `flutter_secure_storage`, `image_picker`, `intl` / generated localizations
5. **Prior ADRs** — API-side only; mobile consumes JWT refresh rules

## Technical Approach

1. **Scaffold**: `flutter create` into `mobile/` (or multi-package layout if needed); keep a practical monorepo-friendly structure under `mobile/lib/` with folders for presentation / domain / data / infrastructure for v1 (separate pub packages can wait if scaffolding cost is high — prefer clear folder boundaries with domain free of Flutter imports)
2. **DI**: GetIt registers API client, repositories, use cases, BLoCs
3. **Navigation**: GoRouter with auth redirect (signed-out → sign-in; signed-in cannot stay on auth routes)
4. **Theme**: Material 3 themed from shared token colors (align with web: forest green primary, light surfaces)
5. **Networking**: Base URL configurable (`http://10.0.2.2:8000` Android emulator / `localhost` iOS sim / LAN IP for device); interceptors for Bearer + refresh
6. **Storage**: `flutter_secure_storage` for access/refresh tokens
7. **Localization**: ARB files `app_en.arb` / `app_bn.arb`; locale toggle in settings or system locale
8. **Parity**: Same validation/error codes as web; signup then navigate to sign-in

## Out of Scope

- Other domain modules (cows, etc.)
- Hosting / store release / CI signing
- Full design-system component library beyond themed Material 3

## Acceptance Criteria

- [ ] Owner can sign up and sign in on mobile against the local API in dev
- [ ] Tokens are stored securely and attached to authenticated requests
- [ ] Owner can sign out; private screens become inaccessible
- [ ] API errors show user-facing `message` consistently with web
- [ ] Auth/settings strings available in Bangla and English
- [ ] Profile and farm settings load/save via API and reflect returned values
- [ ] Critical-path tests pass (domain rules and/or auth BLoC)

## Relevant Prior Decisions

- API JWT rotation/reuse (ADR-003): mobile must force re-login when refresh fails
- Sync SQLAlchemy / Argon2 are server concerns only
