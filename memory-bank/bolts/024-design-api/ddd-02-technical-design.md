---
unit: 001-design-api
bolt: 024-design-api
stage: design
status: complete
updated: "2026-11-12T07:52:07Z"
---

# Technical Design - Design API (production table contracts)

## Architecture Pattern

Extend the existing **modular FastAPI monolith** — primarily the `cows` feature module for milk/feeding totals and mutations, plus **list paging parity** across cows, poultry, crops, inventory, and income/expenses modules.

**Rationale**: Same layered layout as bolts `004-cows` / `019-design-api`; reuses JWT owner deps, error envelope, and `{ items, meta }` paging from `api-conventions.md`. No new top-level bounded context.

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Milk/Feeding update/delete; list paging
├─────────────────────────────────────┤
│ Domain                              │  RowTotal rules; archive write guards
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy + Alembic (unit_cost column)
└─────────────────────────────────────┘
```

### Backend touchpoints (this bolt)

```text
backend/app/modules/cows/
├── domain/           # RowTotal; archive guards for child mutations
├── application/      # update/delete milk & feeding; create/update with unit_cost
├── infrastructure/   # cow_feedings.unit_cost; repository update/delete
└── presentation/     # PATCH/DELETE routes; schemas; OpenAPI

backend/app/modules/{poultry,crops,inventory,income_expenses}/
└── presentation + application  # ensure list default/meta for limit=10 tables
```

Mount remains under `/api/v1`.

## Construction Decisions

| Decision              | Choice                                                                     | Notes                                                                                                                        |
| --------------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Feeding Total         | `quantity × unit_cost`                                                     | Align with milk `quantity × price_per_unit`                                                                                  |
| Feeding `unit_cost`   | **Required** on create and update                                          | Non-negative; Alembic add column; backfill existing rows to `0` then require on new writes                                   |
| Milk Total            | Keep formula; **also return** additive `total` on milk & feeding resources | Clients may still recompute; response field removes ambiguity for tables                                                     |
| Delete semantics      | **Hard-delete**                                                            | Row removed from DB; no soft-delete for sub-records                                                                          |
| Update semantics      | Partial PATCH                                                              | Only provided fields change; recompute `total` when quantity/price/cost change                                               |
| Archived cow          | Block create/**update**/**delete** of milk/feeding                         | `409 COW_ARCHIVED` (same as block add)                                                                                       |
| Cross-owner           | `404` not found                                                            | Do not leak existence                                                                                                        |
| Entity list page size | Clients use **limit=10**; ensure `meta.total` always present               | Change module defaults to **10** where lists are table-backed (or document that clients always pass 10); max remains **100** |
| Milk/feeding list     | Unchanged default **10** from bolt 019                                     | Keep newest-first                                                                                                            |
| ADR needed?           | **No** — extends existing patterns; Stage 3 skip expected                  |                                                                                                                              |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Milk (extend)

| Endpoint                                           | Method | Auth  | Request                            | Response                                    |
| -------------------------------------------------- | ------ | ----- | ---------------------------------- | ------------------------------------------- |
| `/api/v1/cows/{cow_id}/milk-productions`           | POST   | Owner | MilkCreate                         | `201` MilkProduction **(+ `total`)**        |
| `/api/v1/cows/{cow_id}/milk-productions`           | GET    | Owner | `limit` (default **10**), `offset` | `{ items, meta }` items include **`total`** |
| `/api/v1/cows/{cow_id}/milk-productions/{milk_id}` | PATCH  | Owner | MilkUpdate (partial)               | MilkProduction **(+ `total`)**              |
| `/api/v1/cows/{cow_id}/milk-productions/{milk_id}` | DELETE | Owner | —                                  | `204` No Content                            |

### Feeding (extend)

| Endpoint                                      | Method | Auth  | Request                                          | Response                                    |
| --------------------------------------------- | ------ | ----- | ------------------------------------------------ | ------------------------------------------- |
| `/api/v1/cows/{cow_id}/feedings`              | POST   | Owner | FeedingCreate **incl. `unit_cost`**              | `201` CowFeeding **(+ `total`)**            |
| `/api/v1/cows/{cow_id}/feedings`              | GET    | Owner | `limit` (default **10**), `offset`               | `{ items, meta }` items include **`total`** |
| `/api/v1/cows/{cow_id}/feedings/{feeding_id}` | PATCH  | Owner | FeedingUpdate (partial; may include `unit_cost`) | CowFeeding **(+ `total`)**                  |
| `/api/v1/cows/{cow_id}/feedings/{feeding_id}` | DELETE | Owner | —                                                | `204` No Content                            |

### Entity lists (pagination parity)

| Endpoint                                                | Method | Auth  | Query                                                                     | Response                            |
| ------------------------------------------------------- | ------ | ----- | ------------------------------------------------------------------------- | ----------------------------------- |
| `/api/v1/cows`                                          | GET    | Owner | `limit` (prefer default **10** for tables), `offset`, `include_archived?` | `{ items, meta }` with `meta.total` |
| `/api/v1/poultry-groups` (or module’s established path) | GET    | Owner | `limit`, `offset`, filters as today                                       | `{ items, meta }`                   |
| `/api/v1/crop-cycles` (or established path)             | GET    | Owner | `limit`, `offset`                                                         | `{ items, meta }`                   |
| `/api/v1/inventory-items` (or established path)         | GET    | Owner | `limit`, `offset`                                                         | `{ items, meta }`                   |
| `/api/v1/income-expenses` (or ledger path)              | GET    | Owner | `limit`, `offset`, filters                                                | `{ items, meta }`                   |

**Rule**: If a list already returns `meta`, keep shape; ensure `total`/`limit`/`offset` are correct when `limit=10`. If any list lacks paging, add offset/limit + meta in this bolt (minimal change). Exact path names follow existing routers discovered at Implement stage — do not invent alternate URLs.

### Schemas (deltas bold)

**MilkProduction** (response): existing fields + **`total`** (`quantity × price_per_unit`, string/decimal consistent with money fields)

**MilkUpdate**: optional `produced_at`, `quantity`, `unit`, `price_per_unit`, `note`

**CowFeeding** (response): existing + **`unit_cost`** + **`total`** (`quantity × unit_cost`)

**FeedingCreate**: existing + **`unit_cost`** (required, ≥ 0)

**FeedingUpdate**: optional `fed_at`, `feed_name`, `quantity`, `unit`, **`unit_cost`**, `note`

**PageMeta**: `{ total, limit, offset }` — unchanged

## Data Persistence

| Table              | Change                                                         | Notes                                                                            |
| ------------------ | -------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `cow_feedings`     | Add **`unit_cost`** (numeric/decimal, NOT NULL after backfill) | Backfill existing rows to `0`; application requires explicit cost on new creates |
| `milk_productions` | No new column                                                  | `total` is computed in application/response only                                 |
| Entity list tables | No schema change for paging                                    | Query-only                                                                       |

### Migration

Alembic revision:

1. Add `cow_feedings.unit_cost` nullable
2. Backfill `UPDATE cow_feedings SET unit_cost = 0 WHERE unit_cost IS NULL`
3. Alter to NOT NULL (or keep nullable in DB but reject NULL on write — prefer NOT NULL after backfill)

## Security Design

| Concern         | Approach                                                            |
| --------------- | ------------------------------------------------------------------- |
| Authentication  | Existing JWT `get_current_owner`                                    |
| Authorization   | All ops filter by `owner_id`; wrong id → `404`                      |
| Archived writes | Reject milk/feeding PATCH/DELETE/POST with `409 COW_ARCHIVED`       |
| Validation      | `unit_cost` / money / quantity via Pydantic; `422 VALIDATION_ERROR` |

## NFR Implementation

| Requirement    | Design Approach                                                                                                                            |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Performance    | Keep indexed list by `(cow_id, produced_at/fed_at DESC)`; page size 10                                                                     |
| Compatibility  | Additive `total` / `unit_cost` fields; create feeding without `unit_cost` becomes **breaking** — coordinated with web `026` / mobile `028` |
| Contract-first | Update OpenAPI before dependent UI bolts                                                                                                   |

## Error Handling

| Error Type                           | HTTP | Code                                                           |
| ------------------------------------ | ---- | -------------------------------------------------------------- |
| Validation (incl. missing unit_cost) | 422  | `VALIDATION_ERROR`                                             |
| Cow archived (write)                 | 409  | `COW_ARCHIVED`                                                 |
| Milk/feeding not found or not owned  | 404  | `MILK_NOT_FOUND` / `FEEDING_NOT_FOUND` (or shared `NOT_FOUND`) |
| Cow not found / not owned            | 404  | `COW_NOT_FOUND`                                                |
| Unauthorized                         | 401  | `UNAUTHORIZED`                                                 |

## Application Use Cases

| Story                                 | Use cases                                                                                    |
| ------------------------------------- | -------------------------------------------------------------------------------------------- |
| 001-api-feeding-total-and-list-meta   | `CreateFeeding` (+unit_cost), `ListFeedings`/`ListMilk` with `total` + PageMeta              |
| 002-api-milk-feeding-update-delete    | `UpdateMilk`, `DeleteMilk`, `UpdateFeeding`, `DeleteFeeding`                                 |
| 003-api-entity-list-pagination-parity | `ListCows`/`ListPoultry`/`ListCrops`/`ListInventory`/`ListLedger` with PageMeta for limit=10 |

## External Dependencies

| Service    | Purpose                               | Integration          |
| ---------- | ------------------------------------- | -------------------- |
| PostgreSQL | Persist `unit_cost`; hard-delete rows | SQLAlchemy + Alembic |
| Auth       | Owner identity                        | `get_current_owner`  |

## Testing Plan (preview for Stage 5)

- Unit: Total computation for milk and feeding; archive blocks update/delete
- API: POST feeding requires unit_cost; PATCH/DELETE milk & feeding; 404 cross-owner; 409 archived
- API: list pages with `limit=10` return correct `meta.total` for cows + other entity lists
- Migration: existing feedings get unit_cost backfill

## Out of Scope

- Web/mobile UI (bolts 025–028)
- Soft-delete for milk/feeding
- New farm domains
- Changing cow tag/image contracts from bolt 019

## ADR Assessment (preview)

No new architectural pattern or tech choice beyond existing FastAPI modular monolith + offset/limit paging. **Stage 3 ADR analysis: skip** unless Implement discovers a standards conflict.
