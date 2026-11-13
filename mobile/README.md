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

```text
lib/
  domain/          # entities, repository interfaces, use cases (pure Dart)
  data/            # Dio APIs, token store, mappers, repository impl
  presentation/    # pages, cubits, shell, shared widgets (charts, tables, forms)
  infrastructure/  # DI (GetIt), GoRouter, theme, config
  l10n/            # English and Bangla ARB / generated localizations
```

## Related

- Backend API: [`../backend/README.md`](../backend/README.md)
- React web app: [`../web/README.md`](../web/README.md)
- Repo overview: [`../README.md`](../README.md)
- UX conventions: [`../memory-bank/standards/ux-guide.md`](../memory-bank/standards/ux-guide.md)
