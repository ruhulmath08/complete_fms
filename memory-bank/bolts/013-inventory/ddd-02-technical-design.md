---
unit: 005-inventory
bolt: 013-inventory
stage: design
status: complete
updated: 2026-11-09T12:40:00Z
---

# Technical Design - Inventory (API)

## Architecture Pattern

Extend the modular FastAPI monolith with a new `inventory` feature module using the same layered package shape as crops/poultry/cows/auth (Presentation → Application → Domain → Infrastructure).

**Rationale**: Matches system-architecture; reuses JWT owner deps, error handlers, paging helpers, sync SQLAlchemy (ADR-002), soft-archive (ADR-004), and denormalized child `owner_id` (ADR-005).

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  InventoryItemService, StockUpdateService
├─────────────────────────────────────┤
│ Domain                              │  Category, change type, archive, stock math
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy models
└─────────────────────────────────────┘
```

### Backend layout (this bolt)

```text
backend/app/modules/inventory/
├── domain/           # category/change-type/archive/stock rules
├── application/      # InventoryItemService, StockUpdateService
├── infrastructure/   # SQLAlchemy models
└── presentation/     # routers + schemas
```

Mount under `/api/v1` via `api/v1/router.py`.

## Construction Decisions (resolves Open Questions)

| Decision                 | Choice                                                                                    | Notes                                                                               |
| ------------------------ | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Item name uniqueness     | **Not unique**; identity is `id`                                                          | Same pattern as poultry group names                                                 |
| Categories               | Fixed enum                                                                                | `feed`, `fertilizer`, `pesticide`, `seed`, `medicine`, `equipment`, `fuel`, `other` |
| `total_price`            | **Computed on read** as `quantity × price_per_unit`                                       | Included on InventoryItem response; not a DB column                                 |
| Quantity on PATCH        | **Not patchable**                                                                         | Create sets initial `quantity`; later changes only via StockUpdate                  |
| Opening stock ledger row | **None** on create                                                                        | Create sets quantity; stock log starts at first explicit add/use                    |
| Stock update mutations   | **Add + list only** in v1                                                                 | No PATCH/DELETE; correct via compensating update                                    |
| Change model             | `change_type` `add`\|`use` + positive `quantity_change`                                   | Apply +/− to item quantity in one transaction                                       |
| No-negative-stock        | Reject `use` when `quantity_change > current quantity`                                    | `409 INSUFFICIENT_STOCK`; `details` may include `quantity` / `requested`            |
| List paging              | Default `limit=20`, `offset=0`, max `100`                                                 | Items and stock updates                                                             |
| Archived GET             | Allowed                                                                                   | Lists default active; `?include_archived=true`; GET by id includes archived         |
| Writes on archived item  | Rejected                                                                                  | `409 INVENTORY_ITEM_ARCHIVED` for item update + stock add; archive idempotent       |
| Money/quantity precision | `Numeric(12,2)` for `price_per_unit` / derived total; `Numeric(12,3)` for quantity fields | Match prior modules                                                                 |
| Stock date               | Required `date` (`occurred_at`)                                                           | Calendar date of add/use                                                            |
| Unit                     | Free string (max 32), required                                                            | Optional reuse of `/config/suggested-units` on clients later                        |

**No new ADR required** — archive and child `owner_id` reuse ADR-004 / ADR-005; no new uniqueness policy.

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Inventory items

| Endpoint                                    | Method | Auth  | Request                                | Response                            |
| ------------------------------------------- | ------ | ----- | -------------------------------------- | ----------------------------------- |
| `/api/v1/inventory-items`                   | POST   | Owner | ItemCreate                             | `201` InventoryItem                 |
| `/api/v1/inventory-items`                   | GET    | Owner | `limit`, `offset`, `include_archived?` | `{ items, meta }` active by default |
| `/api/v1/inventory-items/{item_id}`         | GET    | Owner | —                                      | InventoryItem (incl. archived)      |
| `/api/v1/inventory-items/{item_id}`         | PATCH  | Owner | ItemUpdate                             | InventoryItem                       |
| `/api/v1/inventory-items/{item_id}/archive` | POST   | Owner | —                                      | InventoryItem (`is_archived=true`)  |

### Stock updates

| Endpoint                                          | Method | Auth  | Request           | Response                       |
| ------------------------------------------------- | ------ | ----- | ----------------- | ------------------------------ |
| `/api/v1/inventory-items/{item_id}/stock-updates` | POST   | Owner | StockUpdateCreate | `201` StockUpdate              |
| `/api/v1/inventory-items/{item_id}/stock-updates` | GET    | Owner | `limit`, `offset` | `{ items, meta }` newest first |

### Schemas (field summary)

**ItemCreate**: `name`, `category`, `quantity` (≥ 0), `unit`, `price_per_unit` (≥ 0), `note?`

**ItemUpdate**: `name?`, `category?`, `unit?`, `price_per_unit?`, `note?` — **no `quantity`**

**InventoryItem** (response): `id`, `name`, `category`, `quantity`, `unit`, `price_per_unit`, `total_price` (computed), `note?`, `is_archived`, `created_at`, `updated_at`

**StockUpdateCreate**: `occurred_at`, `change_type` (`add`\|`use`), `quantity_change` (> 0), `reason?`

**StockUpdate** (response): `id`, `inventory_item_id`, `occurred_at`, `change_type`, `quantity_change`, `reason?`, `created_at`

## Data Persistence

| Table             | Columns                                                                                                                       | Relationships / indexes                               |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `inventory_items` | UUID PK; `owner_id` FK→owners; name; category; quantity; unit; price_per_unit; note; `is_archived`; timestamps                | Index `(owner_id, is_archived)`                       |
| `stock_updates`   | UUID PK; `inventory_item_id` FK→inventory_items; `owner_id` FK; occurred_at; change_type; quantity_change; reason; timestamps | Index `(inventory_item_id, occurred_at)`; index owner |

### Migration

Alembic revision after crops (`20261109_0004`): create `inventory_items` and `stock_updates` with FKs and indexes.

### Apply stock update (application transaction)

1. Load item for owner; 404 if missing; 409 if archived.
2. Validate `quantity_change` > 0 and `change_type` in enum.
3. If `use` and `quantity_change > item.quantity` → `409 INSUFFICIENT_STOCK`.
4. Persist StockUpdate row; set `item.quantity` to `quantity ± quantity_change`; flush/commit.

## Security Design

| Concern        | Approach                                                                       |
| -------------- | ------------------------------------------------------------------------------ |
| Authentication | Existing `get_current_owner`                                                   |
| Authorization  | All queries filter `owner_id`; other-owner id → `404 INVENTORY_ITEM_NOT_FOUND` |
| Validation     | Enums + quantity/price guards + archive + insufficient-stock server-side       |
| Logging        | Mutations at info without secrets                                              |

## NFR Implementation

| Requirement    | Design Approach                                                          |
| -------------- | ------------------------------------------------------------------------ |
| Performance    | Indexed owner/archive and item/time lists; default paging                |
| Reliability    | Postgres + Alembic; single transaction for stock apply + quantity update |
| Contract-first | This design + OpenAPI before web/mobile inventory bolts                  |

## Error Handling

| Error Type            | HTTP | Code                       |
| --------------------- | ---- | -------------------------- |
| Validation            | 422  | `VALIDATION_ERROR`         |
| Insufficient stock    | 409  | `INSUFFICIENT_STOCK`       |
| Item archived (write) | 409  | `INVENTORY_ITEM_ARCHIVED`  |
| Not found / not owned | 404  | `INVENTORY_ITEM_NOT_FOUND` |
| Unauthorized          | 401  | `UNAUTHORIZED`             |

## Application Use Cases

| Story | Use cases                                                                                 |
| ----- | ----------------------------------------------------------------------------------------- |
| 001   | CreateItem, ListItems, GetItem, UpdateItem, ArchiveItem, AddStockUpdate, ListStockUpdates |

## Integrations

| Service                        | Purpose               |
| ------------------------------ | --------------------- |
| PostgreSQL via sync SQLAlchemy | Persistence (ADR-002) |
| Auth `get_current_owner`       | Owner identity        |

## Testing Plan (preview for Stage 5)

- Unit: category/change-type enums; insufficient-stock math; archive write block
- API: item CRUD/archive; create with initial quantity; add increases / use decreases quantity; use below zero → 409; PATCH cannot change quantity; owner isolation
- Security: unauthenticated → 401; other-owner → 404

## Out of Scope

- Web/mobile UI (014/015)
- Unarchive, hard delete, multi-farm
- Stock update edit/delete
- Linking inventory to poultry feeding / crop inputs
- Multi-warehouse / SKU barcodes
