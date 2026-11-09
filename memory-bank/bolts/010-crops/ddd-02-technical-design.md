---
unit: 004-crops
bolt: 010-crops
stage: design
status: complete
updated: 2026-11-09T12:02:06Z
---

# Technical Design - Crops (API)

## Architecture Pattern

Extend the modular FastAPI monolith with a new `crops` feature module using the same layered package shape as poultry/cows/auth (Presentation → Application → Domain → Infrastructure).

**Rationale**: Matches system-architecture; reuses JWT owner deps, error handlers, paging helpers, sync SQLAlchemy (ADR-002), soft-archive (ADR-004), denormalized child `owner_id` (ADR-005), and active-only uniqueness pattern (ADR-006).

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Name / cycle / expense / harvest / summary services
├─────────────────────────────────────┤
│ Domain                              │  Name uniqueness, category, archive, FK rules
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy models
└─────────────────────────────────────┘
```

### Backend layout (this bolt)

```text
backend/app/modules/crops/
├── domain/           # name/category/archive/area rules
├── application/      # CropNameService, CropCycleService, CropExpenseService, HarvestService
├── infrastructure/   # SQLAlchemy models
└── presentation/     # routers + schemas
```

Mount under `/api/v1` via `api/v1/router.py`.

## Construction Decisions (resolves Open Questions)

| Decision                     | Choice                                                                                   | Notes                                                                                                |
| ---------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Active crop-name uniqueness  | Unique `(owner_id, name)` among **active** names only                                    | Partial unique index (ADR-006 pattern); reuse after archive; `409 CROP_NAME_ALREADY_EXISTS`          |
| Cycle → archived crop name   | Existing cycles keep FK; create/PATCH selecting archived name → `422 CROP_NAME_ARCHIVED` | GET cycle still returns archived name id                                                             |
| Area                         | Optional `Numeric(12,3)` only; no area unit enum in v1                                   | ≥ 0 when present                                                                                     |
| Summary                      | `GET /api/v1/crop-cycles/{cycle_id}/summary` computed on read                            | `total_expenses`, `total_sale_income`, `result` (= income − expenses); null sale_amount treated as 0 |
| List paging                  | Default `limit=20`, `offset=0`, max `100`                                                | Names, cycles, expenses, harvests                                                                    |
| Archived GET                 | Allowed                                                                                  | Lists default active; `?include_archived=true`; GET by id includes archived                          |
| Writes on archived cycle     | Rejected                                                                                 | `409 CROP_CYCLE_ARCHIVED` for cycle update + expense/harvest add                                     |
| Writes on archived crop name | Rejected                                                                                 | `409 CROP_NAME_ARCHIVED` for name update; archive is idempotent                                      |
| Expense/harvest mutations    | **Add + list only** in v1                                                                | No PATCH/DELETE (FR: add and review)                                                                 |
| Expense categories           | Fixed enum                                                                               | `labour`, `fertilizers`, `pesticides_and_chemicals`, `seeds`, `irrigation`, `equipment`, `other`     |
| Money/quantity               | `Numeric(12,2)` money; `Numeric(12,3)` quantity/area                                     | expense amount > 0; sale_amount ≥ 0 when set; qty > 0                                                |
| Planted date                 | Required `date` (`planted_at`)                                                           | `expected_harvest_at` optional date                                                                  |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Crop names

| Endpoint                                    | Method | Auth  | Request                                | Response                            |
| ------------------------------------------- | ------ | ----- | -------------------------------------- | ----------------------------------- |
| `/api/v1/crop-names`                        | POST   | Owner | NameCreate                             | `201` CropName                      |
| `/api/v1/crop-names`                        | GET    | Owner | `limit`, `offset`, `include_archived?` | `{ items, meta }` active by default |
| `/api/v1/crop-names/{crop_name_id}`         | GET    | Owner | —                                      | CropName (incl. archived)           |
| `/api/v1/crop-names/{crop_name_id}`         | PATCH  | Owner | NameUpdate                             | CropName                            |
| `/api/v1/crop-names/{crop_name_id}/archive` | POST   | Owner | —                                      | CropName (`is_archived=true`)       |

### Crop cycles

| Endpoint                                 | Method | Auth  | Request                                | Response                            |
| ---------------------------------------- | ------ | ----- | -------------------------------------- | ----------------------------------- |
| `/api/v1/crop-cycles`                    | POST   | Owner | CycleCreate (`crop_name_id` required)  | `201` CropCycle                     |
| `/api/v1/crop-cycles`                    | GET    | Owner | `limit`, `offset`, `include_archived?` | `{ items, meta }` active by default |
| `/api/v1/crop-cycles/{cycle_id}`         | GET    | Owner | —                                      | CropCycle (incl. archived)          |
| `/api/v1/crop-cycles/{cycle_id}`         | PATCH  | Owner | CycleUpdate                            | CropCycle                           |
| `/api/v1/crop-cycles/{cycle_id}/archive` | POST   | Owner | —                                      | CropCycle                           |
| `/api/v1/crop-cycles/{cycle_id}/summary` | GET    | Owner | —                                      | CycleSummary                        |

### Expenses

| Endpoint                                  | Method | Auth  | Request           | Response                       |
| ----------------------------------------- | ------ | ----- | ----------------- | ------------------------------ |
| `/api/v1/crop-cycles/{cycle_id}/expenses` | POST   | Owner | ExpenseCreate     | `201` CropExpense              |
| `/api/v1/crop-cycles/{cycle_id}/expenses` | GET    | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Harvests

| Endpoint                                  | Method | Auth  | Request           | Response                       |
| ----------------------------------------- | ------ | ----- | ----------------- | ------------------------------ |
| `/api/v1/crop-cycles/{cycle_id}/harvests` | POST   | Owner | HarvestCreate     | `201` Harvest                  |
| `/api/v1/crop-cycles/{cycle_id}/harvests` | GET    | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Schemas (field summary)

**CropName**: `id`, `name`, `notes?`, `is_archived`, `created_at`, `updated_at`

**CropCycle**: `id`, `crop_name_id`, `plot_name?`, `area?`, `location?`, `planted_at`, `expected_harvest_at?`, `notes?`, `is_archived`, `created_at`, `updated_at`

**CropExpense**: `id`, `crop_cycle_id`, `spent_at`, `category`, `amount`, `note?`, `created_at`

**Harvest**: `id`, `crop_cycle_id`, `harvested_at`, `quantity`, `unit`, `sale_amount?`, `note?`, `created_at`

**CycleSummary**: `crop_cycle_id`, `total_expenses`, `total_sale_income`, `result`

## Data Persistence

| Table           | Columns                                                                                                                                            | Relationships / indexes                                                         |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `crop_names`    | UUID PK; `owner_id` FK→owners; name; notes; `is_archived`; timestamps                                                                              | Index `(owner_id, is_archived)`; partial unique `(owner_id, name)` WHERE active |
| `crop_cycles`   | UUID PK; `owner_id` FK; `crop_name_id` FK→crop_names; plot_name, area, location, planted_at, expected_harvest_at, notes, `is_archived`, timestamps | Index `(owner_id, is_archived)`; index `crop_name_id`                           |
| `crop_expenses` | UUID PK; `crop_cycle_id` FK; `owner_id` FK; spent_at, category, amount, note, timestamps                                                           | Index `(crop_cycle_id, spent_at)`                                               |
| `harvests`      | UUID PK; `crop_cycle_id` FK; `owner_id` FK; harvested_at, quantity, unit, sale_amount, note, timestamps                                            | Index `(crop_cycle_id, harvested_at)`                                           |

### Migration

Alembic revision after poultry (`20261109_0003`): create four tables with FKs, indexes, and partial unique on active crop names (`sqlite_where` for tests).

## Security Design

| Concern        | Approach                                                                                           |
| -------------- | -------------------------------------------------------------------------------------------------- |
| Authentication | Existing `get_current_owner`                                                                       |
| Authorization  | All queries filter `owner_id`; other-owner id → `404 CROP_NAME_NOT_FOUND` / `CROP_CYCLE_NOT_FOUND` |
| Validation     | Enums + uniqueness + archive guards server-side                                                    |
| Logging        | Mutations at info without secrets                                                                  |

## NFR Implementation

| Requirement    | Design Approach                                                                     |
| -------------- | ----------------------------------------------------------------------------------- |
| Performance    | Indexed owner/archive and cycle/time lists; default paging; summary via SUM queries |
| Reliability    | Postgres + Alembic                                                                  |
| Contract-first | This design + OpenAPI before web/mobile crops bolts                                 |

## Error Handling

| Error Type                         | HTTP      | Code                                                                                 |
| ---------------------------------- | --------- | ------------------------------------------------------------------------------------ |
| Validation                         | 422       | `VALIDATION_ERROR`                                                                   |
| Active crop name duplicate         | 409       | `CROP_NAME_ALREADY_EXISTS`                                                           |
| Crop name archived (select/update) | 422 / 409 | `CROP_NAME_ARCHIVED` (422 when selecting for cycle; 409 when updating archived name) |
| Cycle archived (write)             | 409       | `CROP_CYCLE_ARCHIVED`                                                                |
| Not found / not owned              | 404       | `CROP_NAME_NOT_FOUND` / `CROP_CYCLE_NOT_FOUND`                                       |
| Unauthorized                       | 401       | `UNAUTHORIZED`                                                                       |

## Application Use Cases

| Story | Use cases                                                                                                             |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| 001   | CreateName, ListNames, GetName, UpdateName, ArchiveName, CreateCycle, ListCycles, GetCycle, UpdateCycle, ArchiveCycle |
| 002   | AddExpense, ListExpenses, AddHarvest, ListHarvests, GetCycleSummary                                                   |

## Integrations

| Service                        | Purpose               |
| ------------------------------ | --------------------- |
| PostgreSQL via sync SQLAlchemy | Persistence (ADR-002) |
| Auth `get_current_owner`       | Owner identity        |

## Testing Plan (preview for Stage 5)

- Unit: category enum, archive guards, summary math (null sale → 0)
- API: name CRUD + active uniqueness + reuse after archive; cycle requires valid active name; expense/harvest add/list; summary totals; owner isolation
- Security: unauthenticated → 401; other-owner → 404

## Out of Scope

- Web/mobile UI (011/012)
- Unarchive, hard delete, multi-farm
- Expense/harvest edit/delete
- Double-entry accounting; linking to general income/expenses module
- Area unit catalog
