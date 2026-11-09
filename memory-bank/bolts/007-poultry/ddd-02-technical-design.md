---
unit: 003-poultry
bolt: 007-poultry
stage: design
status: complete
updated: 2026-11-09T11:27:03Z
---

# Technical Design - Poultry (API)

## Architecture Pattern

Extend the modular FastAPI monolith with a new `poultry` feature module using the same layered package shape as cows/auth (Presentation → Application → Domain → Infrastructure).

**Rationale**: Matches system-architecture; reuses JWT owner deps, error handlers, paging helpers, sync SQLAlchemy (ADR-002), soft-archive (ADR-004), and denormalized child `owner_id` (ADR-005).

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Group / feeding / egg services
├─────────────────────────────────────┤
│ Domain                              │  Type, purchase, egg, archive rules
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy models + repositories
└─────────────────────────────────────┘
```

### Backend layout (this bolt)

```text
backend/app/modules/poultry/
├── domain/           # type/purchase/egg/archive rules
├── application/      # PoultryGroupService, PoultryFeedingService, EggProductionService
├── infrastructure/   # SQLAlchemy models, repositories
└── presentation/     # routers + schemas
```

Mount under `/api/v1` via `api/v1/router.py`.

## Construction Decisions (resolves Open Questions)

| Decision           | Choice                                               | Notes                                                                                                        |
| ------------------ | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Poultry types      | `broiler`, `duck`, `layer`, `local`                  | Required enum                                                                                                |
| Group identity     | UUID `id` is the stable identity                     | **Names are not unique** — multiple groups may share the same display name; clients always key by `group_id` |
| List paging        | Default `limit=20`, `offset=0`, max `100`            | Groups, feedings, eggs                                                                                       |
| Archived GET       | Allowed                                              | Lists default active; `?include_archived=true` on group list; GET by id includes archived                    |
| Writes on archived | Rejected                                             | `409 POULTRY_GROUP_ARCHIVED` for update/feeding/egg                                                          |
| Eggs on broiler    | Rejected                                             | `422 EGGS_NOT_ALLOWED_FOR_TYPE`                                                                              |
| Purchase fields    | Required iff `acquired_by=purchased`; null otherwise | `422 PURCHASE_FIELDS_INVALID`                                                                                |
| Bird count         | Integer ≥ 0                                          | Updated via PATCH on group                                                                                   |
| Money/quantity     | `Numeric(12,2)` prices; `Numeric(12,3)` quantities   | qty > 0; prices ≥ 0                                                                                          |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Poultry groups

| Endpoint                                    | Method | Auth  | Request                                | Response                            |
| ------------------------------------------- | ------ | ----- | -------------------------------------- | ----------------------------------- |
| `/api/v1/poultry-groups`                    | POST   | Owner | GroupCreate                            | `201` Group                         |
| `/api/v1/poultry-groups`                    | GET    | Owner | `limit`, `offset`, `include_archived?` | `{ items, meta }` active by default |
| `/api/v1/poultry-groups/{group_id}`         | GET    | Owner | —                                      | Group (incl. archived)              |
| `/api/v1/poultry-groups/{group_id}`         | PATCH  | Owner | GroupUpdate                            | Group                               |
| `/api/v1/poultry-groups/{group_id}/archive` | POST   | Owner | —                                      | Group (`is_archived=true`)          |

### Feeding

| Endpoint                                     | Method | Auth  | Request           | Response                       |
| -------------------------------------------- | ------ | ----- | ----------------- | ------------------------------ |
| `/api/v1/poultry-groups/{group_id}/feedings` | POST   | Owner | FeedingCreate     | `201` Feeding                  |
| `/api/v1/poultry-groups/{group_id}/feedings` | GET    | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Eggs

| Endpoint                                            | Method | Auth  | Request           | Response                       |
| --------------------------------------------------- | ------ | ----- | ----------------- | ------------------------------ |
| `/api/v1/poultry-groups/{group_id}/egg-productions` | POST   | Owner | EggCreate         | `201` EggProduction            |
| `/api/v1/poultry-groups/{group_id}/egg-productions` | GET    | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Schemas (field summary)

**PoultryGroup**: `id`, `poultry_type`, `name`, `bird_count`, `date_acquired?`, `acquired_by`, `purchase_date?`, `purchase_price?`, `notes?`, `is_archived`, `created_at`, `updated_at`

**PoultryFeeding**: `id`, `poultry_group_id`, `fed_at`, `feed_name`, `quantity`, `unit`, `note?`, `created_at`

**EggProduction**: `id`, `poultry_group_id`, `produced_at`, `quantity`, `unit`, `price_per_unit`, `note?`, `created_at`

## Data Persistence

| Table              | Columns                                                                                                                          | Relationships / indexes                                         |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `poultry_groups`   | UUID PK; `owner_id` FK→owners; type, name, bird*count, date_acquired, acquired_by, purchase*\*, notes, `is_archived`, timestamps | Index `(owner_id, is_archived)`; no unique constraint on `name` |
| `poultry_feedings` | UUID PK; `poultry_group_id` FK; `owner_id` FK; fed_at, feed_name, quantity, unit, note, timestamps                               | Index `(poultry_group_id, fed_at)`                              |
| `egg_productions`  | UUID PK; `poultry_group_id` FK; `owner_id` FK; produced_at, quantity, unit, price_per_unit, note, timestamps                     | Index `(poultry_group_id, produced_at)`                         |

### Migration

Alembic revision after cows: create three tables with FKs and indexes.

## Security Design

| Concern        | Approach                                                                      |
| -------------- | ----------------------------------------------------------------------------- |
| Authentication | Existing `get_current_owner`                                                  |
| Authorization  | All queries filter `owner_id`; other-owner id → `404 POULTRY_GROUP_NOT_FOUND` |
| Validation     | Enums + purchase/egg/archive rules server-side                                |
| Logging        | Mutations at info without secrets                                             |

## NFR Implementation

| Requirement    | Design Approach                                            |
| -------------- | ---------------------------------------------------------- |
| Performance    | Indexed owner/archive and group/time lists; default paging |
| Reliability    | Postgres + Alembic                                         |
| Contract-first | This design + OpenAPI before web/mobile poultry bolts      |

## Error Handling

| Error Type              | HTTP | Code                        |
| ----------------------- | ---- | --------------------------- |
| Validation              | 422  | `VALIDATION_ERROR`          |
| Invalid purchase fields | 422  | `PURCHASE_FIELDS_INVALID`   |
| Eggs on broiler         | 422  | `EGGS_NOT_ALLOWED_FOR_TYPE` |
| Group archived (write)  | 409  | `POULTRY_GROUP_ARCHIVED`    |
| Not found / not owned   | 404  | `POULTRY_GROUP_NOT_FOUND`   |
| Unauthorized            | 401  | `UNAUTHORIZED`              |

## Application Use Cases

| Story | Use cases                                                      |
| ----- | -------------------------------------------------------------- |
| 001   | CreateGroup, ListGroups, GetGroup, UpdateGroup, ArchiveGroup   |
| 002   | AddFeeding, ListFeedings, AddEggProduction, ListEggProductions |

## Integrations

| Service                        | Purpose               |
| ------------------------------ | --------------------- |
| PostgreSQL via sync SQLAlchemy | Persistence (ADR-002) |
| Auth `get_current_owner`       | Owner identity        |

## Testing Plan (preview for Stage 5)

- Unit: type/purchase/egg/archive rules
- API: CRUD groups, bird_count update, archive list exclusion, feeding any type, eggs eligibility, owner isolation
- Security: unauthenticated → 401; other-owner group → 404

## Out of Scope

- Web/mobile UI (008/009)
- Unarchive, hard delete, multi-farm
- Inventory linkage for feed stock
- Per-bird individual identity (groups only)
