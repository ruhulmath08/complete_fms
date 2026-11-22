# Coding Standards

## Overview

Practical multi-client standards for FastAPI, React (Vite), and Flutter. Prefer language defaults, enforce format/lint tooling, and keep organization aligned with the product specs so AI agents place code correctly.

## Code Formatting

**Tools**:

- Python: Ruff formatter
- TypeScript/React: Prettier
- Dart/Flutter: `dart format`

**Key Settings**:

- Prefer tool defaults unless a project config says otherwise
- Keep formatting automatic (editor on-save and/or CI later)

**Enforcement**: Format before merge; prefer on-save in the IDE during local development

## Linting

**Tools / Strictness**: Balanced

- Python: Ruff lint + mypy (typed public APIs and new code)
- TypeScript: ESLint + TypeScript `strict`
- Flutter: `flutter analyze`

**Key Rules**:

- Prefer typed interfaces at API boundaries
- No unused imports/vars as errors where tooling supports it
- Avoid `any` in TypeScript; use `unknown` and narrow
- Domain Dart stays free of Flutter/data-layer imports

## Naming Conventions

Follow language defaults, plus explicit file/API naming:

| Surface    | Element             | Convention                            | Example                               |
| ---------- | ------------------- | ------------------------------------- | ------------------------------------- |
| Python     | modules/functions   | snake_case                            | `milk_production.py`, `get_cow_by_id` |
| Python     | classes             | PascalCase                            | `CowService`                          |
| Python     | constants           | UPPER_SNAKE                           | `MAX_LOGIN_ATTEMPTS`                  |
| TypeScript | variables/functions | camelCase                             | `isSignedIn`, `getInventoryItem`      |
| TypeScript | components/types    | PascalCase                            | `CowDetailPage`, `MilkEntry`          |
| TypeScript | util files          | kebab-case                            | `date-utils.ts`                       |
| TypeScript | component files     | PascalCase or kebab feature folders   | `CowList.tsx` / `cows/`               |
| Dart       | types/classes       | PascalCase                            | `PoultryGroup`                        |
| Dart       | members/files       | lowerCamelCase / snake_case files     | `birdCount`, `poultry_group.dart`     |
| API        | resources/fields    | plural nouns / snake_case JSON fields | `/cows`, `tag_number`                 |

**Booleans**: prefer `is` / `has` / `can` prefixes (`is_archived`, `hasPermission`).

## File Organization

**Pattern**: Match product specs

```text
complete_fms/
├── backend/          # FastAPI modules by domain
│   └── ... auth, cows, poultry, crops, inventory, income_expenses
├── web/              # React Vite SPA by feature
│   └── src/features/...
└── mobile/           # Flutter Clean Architecture (single package)
    └── lib/
        ├── infrastructure/   # DI, router, theme, config
        ├── presentation/     # pages, blocs, cubits, widgets by feature
        ├── domain/           # pure Dart: entities, repos, use_cases
        ├── data/             # models, datasources, mappers, repo impls, network
        └── l10n/
```

**Domain folders** (keep the same names across layers): `auth/`, `cow/`, `crop/`, `poultry/`, `inventory/`, `ledger/`, `dashboard/`, `common/`.

**Mobile layout for a feature** (example: cow):

```text
domain/entities/cow/          # *Entity, one type per *_entity.dart; direct imports
domain/repositories/cow/
domain/use_cases/cow/         # cows_usecases.dart, or one file per use case
data/models/cow/              # *Model JSON DTOs + fromJson
data/mappers/cow/             # Model → Entity (and write JSON helpers)
data/datasources/cow/         # abstract + Impl
data/repositories/cow/        # orchestrates datasources; maps models → entities
presentation/cows/            # UI feature folder (plural OK for screens)
```

**Mobile conventions**:

- Domain and data are folders in the `mobile` package, not separate pub packages
- Domain stays pure Dart: no Flutter, Dio, models, mappers, or datasource/repo implementations
- Name domain types `*Entity` and files `*_entity.dart`. One public type per file. Import the file directly; do not add a barrel
- Name JSON DTOs `*Model`. Map with functions in `data/mappers/{domain}/`
- Domain owns `Failure` (`domain/failures.dart`) and `Result<T>` (`domain/result.dart`). `Result` is `Success` or `Err`; callers use `.when` or `.fold`
- `ApiClient` (`data/network/api_client.dart`) is the only HTTP entry. It throws `Failure` after interceptors run. Do not add per-domain `*Api` clients
- Auth repositories wrap calls in `safeApiCall` (`data/network/safe_api_call.dart`) and return `Result<T>`. Other domain repositories map models to entities and let `Failure` propagate; pages catch `on Failure`. Match the domain you are extending
- Data flow: API JSON → `*Model.fromJson` → mapper → `*Entity` → repository → use case → presentation
- Datasources: declare an abstract class and a `*Impl`; register the abstract in GetIt
- Multi-source only when needed (auth): `AuthRemoteDatasource` + `AuthLocalDatasource`. Other domains keep one `*Datasource` + Impl
- Interceptor order on the shared Dio client: connectivity, auth (Bearer token and one in-flight refresh), retry, then debug JSON log. Timeouts and retry delays live in `data/network/dio/dio_config.dart`. Tokens come from `AuthLocalDatasource`
- POST, PATCH, PUT, and DELETE notify `ApiActivity`. `LoadingCubit` turns that into the farm loading overlay. Reads are not tracked
- UI widgets come from `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart`. Do not import `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Theme stays Material 3 via `AppTheme` / `AppTokens`
- App-wide state: `SessionCubit`, `LocaleCubit`, and `LoadingCubit` (GetIt lazy singletons, provided on `FarmManagerApp`). Sign-in is `SignInBloc` (GetIt factory) and calls `SignInUseCase`. List, detail, and create pages are `StatefulWidget`s that call use cases from GetIt. A new form that owns validation and submit state follows `SignInBloc`
- Shared paging helpers: `data/models/common/`, `data/repositories/common/`, domain type `PagedResultEntity`
- When adding a feature, create matching folders in domain + data + presentation and wire DI in `infrastructure/di/injection.dart`

**Other conventions**:

- Backend: one module per domain capability; business rules in backend
- Web: feature-based folders; shared UI under `shared/`
- Tests: co-located or adjacent `tests/` per package; prefer behavior-focused names

## Testing Strategy

**Frameworks**:

- Backend: pytest (unit + API tests)
- Web: Vitest + Testing Library
- Mobile: Flutter `test` (domain, mappers, cubit/bloc, and widget tests)

**Coverage Target**: Critical paths over a hard percentage for v1  
Prioritize auth, ownership isolation, inventory no-negative-stock, and crop summary math.

**Conventions**:

- Arrange–Act–Assert
- Test behavior at boundaries; mock external systems sparingly
- Document API contracts before wiring dependent client screens

## Error Handling

**Pattern**: Throw/map domain and validation failures in FastAPI to a consistent JSON body

**API Errors**:

```json
{
  "code": "STOCK_BELOW_ZERO",
  "message": "Stock quantity cannot go below zero.",
  "details": {}
}
```

- Use appropriate HTTP status codes
- Clients display user-facing `message`; use `code` for branching
- Keep technical detail out of end-user copy

## Logging

**Tool**: Python standard `logging` (structured/JSON-friendly later if needed)  
**Clients**: Light error logging in debug builds only

**Levels**:

| Level | Usage                                |
| ----- | ------------------------------------ |
| error | Failures needing attention           |
| warn  | Recoverable unexpected states        |
| info  | Auth and significant business events |
| debug | Detailed diagnostics (local/dev)     |

**Rules**:

- Always log: auth success/failure (without secrets), unhandled API errors, important mutations when useful
- Never log: passwords, tokens, raw profile image binaries, unnecessary PII
