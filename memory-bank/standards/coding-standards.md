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
└── mobile/           # Flutter Clean Architecture
    ├── infrastructure/
    ├── presentation/
    ├── domain/       # separate pure Dart project
    └── data/         # separate project (API, models, mappers, repos)
```

**Conventions**:

- Backend: one module per domain capability; business rules in backend
- Web: feature-based folders; shared UI under `shared/`
- Mobile: infrastructure / presentation / domain / data; domain has no API/data models/mappers/repo implementations
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
