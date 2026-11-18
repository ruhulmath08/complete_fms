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
        ├── presentation/     # pages, cubits, widgets by feature
        ├── domain/           # pure Dart: entities, repos, usecases
        ├── data/             # models, datasources, mappers, repo impls
        └── l10n/
```

**Domain folders** (keep the same names across layers): `auth/`, `cow/`, `crop/`, `poultry/`, `inventory/`, `ledger/`, `dashboard/`, `common/`.

**Mobile layout for a feature** (example: cow):

```text
domain/entities/cow/          # one type per file; import entities directly (no mega-barrel)
domain/repositories/cow/
domain/usecases/cow/
data/models/cow/              # JSON DTOs + fromJson
data/mappers/cow/             # Model → Entity (and write JSON helpers)
data/datasources/cow/         # abstract + Impl
data/repositories/cow/        # orchestrates datasources; maps models → entities
presentation/cows/            # UI feature folder (plural OK for screens)
```

**Mobile conventions**:

- Domain stays pure Dart: no Flutter, Dio, models, mappers, or datasource/repo implementations
- One public type per file under `domain/entities/...`; prefer direct imports over barrel exports
- Data flow: API JSON → `models` → `mappers` → `entities` → repository → use cases → presentation
- Datasources: declare an abstract class and a `*Impl`; register the abstract in GetIt
- Multi-source only when needed (e.g. auth): `AuthRemoteDatasource` + `AuthLocalDatasource`; single-source domains keep one `*Datasource` + Impl (no empty local/remote folders)
- Shared HTTP: `data/datasources/common/api_client.dart` (auth local datasource supplies tokens / refresh)
- Shared paging helpers: `data/models/common/`, `data/repositories/common/`
- When adding a feature, create matching folders in domain + data + presentation and wire DI — do not leave types in flat `entities/` or `*_api.dart` files

**Other conventions**:

- Backend: one module per domain capability; business rules in backend
- Web: feature-based folders; shared UI under `shared/`
- Tests: co-located or adjacent `tests/` per package; prefer behavior-focused names

## Testing Strategy

**Frameworks**:

- Backend: pytest (unit + API tests)
- Web: Vitest + Testing Library
- Mobile: Flutter `test` (domain and BLoC-focused)

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
