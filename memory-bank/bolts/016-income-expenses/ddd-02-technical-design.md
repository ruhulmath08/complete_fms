---
unit: 006-income-expenses
bolt: 016-income-expenses
stage: design
status: complete
updated: 2026-11-09T13:15:17Z
---

# Technical Design - Income and Expenses (API)

## Architecture Pattern

Extend the modular FastAPI monolith with a new `income_expenses` (or `ledger`) feature module using the same layered package shape as inventory/crops/poultry/cows/auth (Presentation → Application → Domain → Infrastructure).

**Rationale**: Matches system-architecture; reuses JWT owner deps, error handlers, paging helpers, sync SQLAlchemy (ADR-002), and soft-archive write-block (ADR-004). Single aggregate table — no child table (ADR-005 not applicable here).

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  LedgerEntryService, PeriodTotalsService
├─────────────────────────────────────┤
│ Domain                              │  Entry type/category, archive, totals rules
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy models
└─────────────────────────────────────┘
```

### Backend layout (this bolt)

```text
backend/app/modules/income_expenses/
├── domain/           # entry type/category/archive/totals rules
├── application/      # LedgerEntryService, PeriodTotalsService
├── infrastructure/   # SQLAlchemy models
└── presentation/     # routers + schemas
```

Mount under `/api/v1` via `api/v1/router.py`.

## Construction Decisions (resolves Open Questions)

| Decision                  | Choice                                                                        | Notes                                                                                                                     |
| ------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Resource path             | `/api/v1/ledger-entries`                                                      | Clear “general ledger”; avoids conflating with crop expenses                                                              |
| `amount` vs `total_price` | **`amount` required money (> 0)**; **`total_price` = `amount` on read**       | Not a DB column; FR lists both — clients get both fields; period totals sum `amount`                                      |
| `unit`                    | Optional free string (max 32)                                                 | Contextual label only; not used in totals                                                                                 |
| Categories                | Fixed shared enum (same set for income and expense)                           | `labour`, `feed_or_supplies`, `utilities`, `transport`, `equipment`, `livestock_sale`, `product_sale`, `subsidy`, `other` |
| Crop double-count         | **No API link to Crops**; totals sum only `ledger_entries`                    | Docs/OpenAPI description: crop-cycle costs belong in Crops module                                                         |
| List filters              | Active by default; `include_archived?`; optional `from`/`to` on `occurred_at` | Same date semantics as totals                                                                                             |
| Totals endpoint           | `GET /api/v1/ledger-entries/totals?from=&to=`                                 | Returns `total_income`, `total_expenses`, `net` (`income − expenses`); archived excluded                                  |
| Date range                | Inclusive `[from, to]` on calendar `occurred_at`; both required on totals     | `from > to` → 422; missing → 422                                                                                          |
| Mutations                 | Full create/update of non-archived; archive only (no hard delete)             | Update may change type/category/date/amount/unit/note                                                                     |
| List paging               | Default `limit=20`, `offset=0`, max `100`                                     | Newest `occurred_at` then `created_at` first                                                                              |
| Archived GET              | Allowed by id; lists default active                                           | Writes on archived → `409 LEDGER_ENTRY_ARCHIVED`                                                                          |
| Money precision           | `Numeric(12,2)` for `amount`                                                  | Match inventory/crops money fields                                                                                        |
| Entry date                | Required `date` (`occurred_at`)                                               | Calendar date of the income/expense                                                                                       |

**No new ADR required** — soft-archive reuses ADR-004; no uniqueness policy; no child denormalization.

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Ledger entries

| Endpoint                                    | Method | Auth  | Request                                                | Response                            |
| ------------------------------------------- | ------ | ----- | ------------------------------------------------------ | ----------------------------------- |
| `/api/v1/ledger-entries`                    | POST   | Owner | LedgerEntryCreate                                      | `201` LedgerEntry                   |
| `/api/v1/ledger-entries`                    | GET    | Owner | `limit`, `offset`, `include_archived?`, `from?`, `to?` | `{ items, meta }` active by default |
| `/api/v1/ledger-entries/totals`             | GET    | Owner | `from` (required), `to` (required)                     | PeriodTotals                        |
| `/api/v1/ledger-entries/{entry_id}`         | GET    | Owner | —                                                      | LedgerEntry (incl. archived)        |
| `/api/v1/ledger-entries/{entry_id}`         | PATCH  | Owner | LedgerEntryUpdate                                      | LedgerEntry                         |
| `/api/v1/ledger-entries/{entry_id}/archive` | POST   | Owner | —                                                      | LedgerEntry (`is_archived=true`)    |

Route order: register `/totals` before `/{entry_id}` so path matching is unambiguous.

### Schemas (field summary)

**LedgerEntryCreate**: `entry_type` (`income`\|`expense`), `occurred_at`, `category`, `amount` (> 0), `unit?`, `note?`

**LedgerEntryUpdate**: `entry_type?`, `occurred_at?`, `category?`, `amount?` (> 0 when present), `unit?`, `note?`

**LedgerEntry** (response): `id`, `entry_type`, `occurred_at`, `category`, `amount`, `unit?`, `total_price` (equals `amount`), `note?`, `is_archived`, `created_at`, `updated_at`

**PeriodTotals** (response): `from`, `to`, `total_income`, `total_expenses`, `net`

## Data Persistence

| Table            | Columns                                                                                                           | Relationships / indexes                                   |
| ---------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `ledger_entries` | UUID PK; `owner_id` FK→owners; entry_type; occurred_at; category; amount; unit?; note?; `is_archived`; timestamps | Index `(owner_id, is_archived, occurred_at)`; index owner |

No child tables. No FK to crops/inventory.

### Migration

Alembic revision after inventory (`20261109_0005`): create `ledger_entries` with FKs and indexes (`20261109_0006`).

### Period totals (application)

1. Validate `from`/`to` present and `from ≤ to`.
2. Sum `amount` where `owner_id` matches, `is_archived = false`, `occurred_at` in inclusive range, grouped by `entry_type`.
3. Return zeros when no rows; `net = total_income − total_expenses`.

## Security Design

| Concern        | Approach                                                                     |
| -------------- | ---------------------------------------------------------------------------- |
| Authentication | Existing `get_current_owner`                                                 |
| Authorization  | All queries filter `owner_id`; other-owner id → `404 LEDGER_ENTRY_NOT_FOUND` |
| Validation     | Enums + amount > 0 + date range + archive write block server-side            |
| Logging        | Mutations at info without secrets                                            |

## NFR Implementation

| Requirement    | Design Approach                                               |
| -------------- | ------------------------------------------------------------- |
| Performance    | Indexed owner/archive/date lists; default paging; SQL SUM     |
| Reliability    | Postgres + Alembic; sync SQLAlchemy (ADR-002)                 |
| Contract-first | This design + OpenAPI before web/mobile income-expenses bolts |

## Error Handling

| Error Type             | HTTP | Code                     |
| ---------------------- | ---- | ------------------------ |
| Validation             | 422  | `VALIDATION_ERROR`       |
| Entry archived (write) | 409  | `LEDGER_ENTRY_ARCHIVED`  |
| Not found / not owned  | 404  | `LEDGER_ENTRY_NOT_FOUND` |
| Unauthorized           | 401  | `UNAUTHORIZED`           |

## Application Use Cases

| Story | Use cases                                                                      |
| ----- | ------------------------------------------------------------------------------ |
| 001   | CreateEntry, ListEntries, GetEntry, UpdateEntry, ArchiveEntry, GetPeriodTotals |

## Integrations

| Service                        | Purpose               |
| ------------------------------ | --------------------- |
| PostgreSQL via sync SQLAlchemy | Persistence (ADR-002) |
| Auth `get_current_owner`       | Owner identity        |

Explicit non-integration: Crops module expenses/harvests are never queried for ledger totals.

## Testing Plan (preview for Stage 5)

- Unit: entry type/category enums; totals math (income/expense/net); archive write block
- API: entry CRUD/archive; list date filters; totals for range; archived excluded from totals; `total_price` equals `amount`; owner isolation
- Security: unauthenticated → 401; other-owner → 404

## Out of Scope

- Web/mobile UI (017/018)
- Unarchive, hard delete, multi-farm
- Importing or syncing crop-cycle expenses/harvest sales into the ledger
- Receipts/attachments, multi-currency, tax codes
- Recurring entries / budgets / forecasting
