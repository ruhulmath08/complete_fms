---
unit: 002-cows
bolt: 004-cows
stage: design
status: complete
updated: 2026-11-09T10:15:40Z
---

# Technical Design - Cows (API)

## Architecture Pattern

Extend the existing **modular FastAPI monolith** with a new `cows` feature module using the same layered package shape as auth (Presentation → Application → Domain → Infrastructure).

**Rationale**: Matches system-architecture; reuses owner JWT deps, error handlers, paging helpers, and sync SQLAlchemy (ADR-002).

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Cow / milk / feeding services
├─────────────────────────────────────┤
│ Domain                              │  Rules (purpose, purchase, archive)
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy models + repositories
└─────────────────────────────────────┘
```

### Backend layout (this bolt)

```text
backend/app/modules/cows/
├── domain/           # purpose/acquisition/archive rules
├── application/      # CowService, MilkProductionService, CowFeedingService
├── infrastructure/   # SQLAlchemy models, repositories
└── presentation/     # routers + schemas
```

Mount under existing `/api/v1` via `api/v1/router.py`.

## Construction Decisions (resolves Open Questions)

| Decision | Choice | Notes |
|----------|--------|-------|
| Gender values | `female`, `male`, `unknown` | Required enum |
| Tag uniqueness | Unique among **active** cows per `owner_id` | Partial unique index `(owner_id, tag_number) WHERE is_archived = false` (or equivalent). Archived cows keep their historical tag; a new active cow may reuse a tag previously held by an archived cow. Creating/updating an active cow with a tag already used by another **active** cow → `409 TAG_ALREADY_EXISTS` |
| List paging | Default `limit=20`, `offset=0`, max `100` | Active cows, milk lists, feeding lists |
| Archived cow GET | Allowed | `GET /cows/{id}` returns archived; lists default to active only; `?include_archived=true` optional for cows list |
| New entries on archived | Rejected | `409 COW_ARCHIVED` for milk/feeding/update (except unarchive not in v1) |
| Milk on meat-only | Rejected | `422 MILK_NOT_ALLOWED_FOR_PURPOSE` |
| Purchase fields | Required iff `acquired_by=purchased`; forbidden/null otherwise | `422 PURCHASE_FIELDS_INVALID` |
| Money/quantity | `Numeric(12,2)` for prices; `Numeric(12,3)` for quantities | Validate > 0 for quantities; ≥ 0 for prices |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Cows

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows` | POST | Owner | CowCreate | `201` Cow |
| `/api/v1/cows` | GET | Owner | query: `limit`, `offset`, `include_archived?` | `{ items, meta }` active by default |
| `/api/v1/cows/{cow_id}` | GET | Owner | — | Cow (incl. archived) |
| `/api/v1/cows/{cow_id}` | PATCH | Owner | CowUpdate | Cow |
| `/api/v1/cows/{cow_id}/archive` | POST | Owner | — | Cow (`is_archived=true`) |

### Milk

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows/{cow_id}/milk-productions` | POST | Owner | MilkCreate | `201` MilkProduction |
| `/api/v1/cows/{cow_id}/milk-productions` | GET | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Feeding

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows/{cow_id}/feedings` | POST | Owner | FeedingCreate | `201` CowFeeding |
| `/api/v1/cows/{cow_id}/feedings` | GET | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Schemas (field summary)

**Cow**: `id`, `tag_number`, `name?`, `breed?`, `date_of_birth?`, `purpose`, `gender`, `color?`, `weight?`, `age?`, `acquired_by`, `purchase_date?`, `purchase_price?`, `notes?`, `is_archived`, `created_at`, `updated_at`

**MilkProduction**: `id`, `cow_id`, `produced_at`, `quantity`, `unit`, `price_per_unit`, `note?`, `created_at`

**CowFeeding**: `id`, `cow_id`, `fed_at`, `feed_name`, `quantity`, `unit`, `note?`, `created_at`

## Data Persistence

| Table | Columns | Relationships / indexes |
|-------|---------|-------------------------|
| `cows` | UUID PK; `owner_id` FK→owners; tag, purpose, gender, acquired_by, purchase_*, optionals, `is_archived`, timestamps | Partial unique `(owner_id, tag_number) WHERE NOT is_archived`; index `(owner_id, is_archived)` |
| `milk_productions` | UUID PK; `cow_id` FK; `owner_id` FK; `produced_at`, quantity, unit, price_per_unit, note, timestamps | Index `(cow_id, produced_at DESC)` |
| `cow_feedings` | UUID PK; `cow_id` FK; `owner_id` FK; `fed_at`, feed_name, quantity, unit, note, timestamps | Index `(cow_id, fed_at DESC)` |

### Migration

Alembic revision after auth: create three tables with FKs and indexes.

## Security Design

| Concern | Approach |
|---------|----------|
| Authentication | Existing JWT access via `get_current_owner` |
| Authorization | Every query/command filters by `owner_id`; 404 if cow not owned (no leak across owners) |
| Validation | Server-side enums + purchase/milk/archive rules |
| Logging | Mutations at info without secrets |

## NFR Implementation

| Requirement | Design Approach |
|-------------|-----------------|
| Performance | Indexed owner/archive and cow/time lists; default paging |
| Reliability | Postgres + Alembic |
| Contract-first | This design + OpenAPI from FastAPI before web/mobile cows bolts |

## Error Handling

| Error Type | HTTP | Code |
|------------|------|------|
| Validation | 422 | `VALIDATION_ERROR` |
| Invalid purchase fields | 422 | `PURCHASE_FIELDS_INVALID` |
| Milk on meat cow | 422 | `MILK_NOT_ALLOWED_FOR_PURPOSE` |
| Duplicate tag | 409 | `TAG_ALREADY_EXISTS` |
| Cow archived (write) | 409 | `COW_ARCHIVED` |
| Not found / not owned | 404 | `COW_NOT_FOUND` |
| Unauthorized | 401 | `UNAUTHORIZED` |

## Application Use Cases

| Story | Use cases |
|-------|-----------|
| 001 | CreateCow, ListCows, GetCow, UpdateCow, ArchiveCow |
| 002 | AddMilkProduction, ListMilkProductions, AddCowFeeding, ListCowFeedings |

## Integrations

| Service | Purpose |
|---------|---------|
| PostgreSQL via sync SQLAlchemy | Persistence (ADR-002) |
| Auth `get_current_owner` | Owner identity |

## Testing Plan (preview for Stage 5)

- Unit: purpose/purchase/archive rules
- API: CRUD cows, archive list exclusion, milk eligibility, feeding for any cow, owner isolation
- Security: unauthenticated → 401; other-owner cow id → 404

## Out of Scope

- Web/mobile UI (005/006)
- Unarchive, hard delete, multi-farm
- Inventory linkage for feed stock
