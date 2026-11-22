# Mobile app

Flutter Clean Architecture client for the same single-farm owner workflows as the web app: Dashboard analytics, cows, poultry, crops, inventory, income/expenses, profile, and farm settings. English and Bangla localization.

## Features

| Area                  | What you can do                                                                                                                                                                                                        |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dashboard**         | Post-login home. Period day / week / month / year (default **this week**). Charts for egg production, hen headcount, milk, cow production, expenses/cost, and income. Future dates blocked in the farm local timezone. |
| **Auth & account**    | Sign up (profile image required), sign in / out, profile with full-image preview, farm settings (currency).                                                                                                            |
| **Cows**              | List / create / detail with cow image; milk and feeding histories with **Total**, **Edit** / **Delete** (confirm).                                                                                                     |
| **Poultry**           | Groups; egg and feeding histories with Action / Total / **No.** parity with cows.                                                                                                                                      |
| **Crops**             | Crop names and cycles; expenses and harvests with Edit / Delete.                                                                                                                                                       |
| **Inventory**         | Items and stock updates; fertilizer-category stock history as a paginated Action-capable table.                                                                                                                        |
| **Income & expenses** | Ledger with date-range totals and a trend graph for the applied range.                                                                                                                                                 |

Signed-in shell: navigation drawer (domain destinations + profile / farm settings), TitleBar overflow with Profile and Logout (logout confirms). Tokens mirror the web primary green where practical (`AppTokens` / Material 3).

## Setup

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run
```

Requires the backend API (see [`../backend/README.md`](../backend/README.md)). For demo login: `demo@completefms.com` / `Password1` after seeding.

## API base URL

Default: `http://10.0.2.2:8000` (Android emulator → host machine).

Override:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Use your machine LAN IP for a physical device.

## Scripts / checks

- `flutter test` — unit and widget tests
- `flutter gen-l10n` — regenerate EN/BN from ARB
- `flutter analyze` — static analysis

## Structure

Clean Architecture in **one** Flutter package. Domain folders are mirrored across layers (`auth`, `cow`, `crop`, `poultry`, `inventory`, `ledger`, `dashboard`, `common`). Domain stays pure Dart.

```text
lib/
  domain/
    entities/{domain}/       # *Entity, one type per *_entity.dart file
    repositories/{domain}/   # abstract repositories
    use_cases/{domain}/      # one action class per use case
    failures.dart            # Failure
    result.dart              # Result / Success / Err (auth)
  data/
    models/{domain}/         # *Model JSON DTOs + fromJson
    mappers/{domain}/        # Model → Entity
    datasources/{domain}/    # abstract + Impl (auth: remote + local)
    repositories/{domain}/   # impls; models → entities
    network/                 # one Dio ApiClient
      dio/interceptors/      # connectivity, auth refresh, retry, debug log
  presentation/              # pages, blocs, cubits, shell, shared widgets
  infrastructure/            # GetIt, GoRouter, Material 3 theme, config
  l10n/                      # English and Bangla ARB / generated localizations
```

Request path: API JSON → `*Model` → mapper → `*Entity` → repository → use case → page.

`ApiClient` is the only HTTP entry. Interceptors run in order: connectivity, Bearer token plus one shared refresh, retry, then a debug JSON log. It throws `Failure` instead of `DioException`. Auth repositories wrap that in `safeApiCall` and return `Result`. Other domains let `Failure` reach the page.

Widgets come from `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart`. Theme tokens stay Material 3 (`AppTheme` / `AppTokens`).

App-wide state is `SessionCubit`, `LocaleCubit`, and `LoadingCubit` (write requests drive the farm loading overlay). Sign-in is `SignInBloc`. List, detail, and create pages call use cases from GetIt.

Folder rules for new features: [`../memory-bank/standards/coding-standards.md`](../memory-bank/standards/coding-standards.md).

## Related

- Backend API: [`../backend/README.md`](../backend/README.md)
- React web app: [`../web/README.md`](../web/README.md)
- Repo overview: [`../README.md`](../README.md)
- UX conventions: [`../memory-bank/standards/ux-guide.md`](../memory-bank/standards/ux-guide.md)
- Coding standards (mobile layout): [`../memory-bank/standards/coding-standards.md`](../memory-bank/standards/coding-standards.md)
