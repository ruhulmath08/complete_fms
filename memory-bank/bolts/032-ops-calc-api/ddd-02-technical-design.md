---
unit: 001-ops-calc-api
bolt: 032-ops-calc-api
stage: design
status: complete
updated: '2026-11-13T07:10:00Z'
---

# Technical Design - 032-ops-calc-api

## Architecture Pattern

Extend the existing **modular FastAPI monolith** across `crops`, `inventory`, `income_expenses` (ledger), `cows`, `poultry`, and `auth`/farm-settings — additive routes and services only. No new top-level bounded context package beyond a thin **dashboard** application facade that reads from existing modules.

**Rationale**: Matches bolts `010-crops`, `013-inventory`, `016-income-expenses`, `024`/`029` mutation patterns; reuses JWT owner deps, error envelope, `{ items, meta }` paging, and hard-delete for history children.

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  Routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Mutation / query / aggregate services
├─────────────────────────────────────┤
│ Domain                              │  Archive guards, FarmClock, series rules
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy + Alembic (timezone if needed)
└─────────────────────────────────────┘
```

### Backend touchpoints (this bolt)

```text
backend/app/modules/crops/
├── application/   # CropExpenseService / HarvestService update+delete
└── presentation/  # PATCH/DELETE expense & harvest routes + update schemas

backend/app/modules/inventory/
├── application/   # FertilizerStockQueryService (cross-item list)
└── presentation/  # GET fertilizer (or category-filtered) stock-updates list

backend/app/modules/income_expenses/
├── application/   # LedgerSeriesService (extend PeriodTotalsService)
└── presentation/  # GET /ledger-entries/series

backend/app/modules/dashboard/   # NEW thin module (or auth-adjacent)
├── application/   # DashboardAggregateService
├── domain/        # FarmClock helpers (or shared)
└── presentation/  # GET /dashboard/aggregates

backend/app/modules/auth/ (or farm_settings)
└── …              # Optional timezone on FarmSettings + GET/PATCH

backend/tests/
├── integration/   # crops mutations, fertilizer list, series, dashboard
└── security/      # unauthenticated / cross-owner
```

Mount remains under `/api/v1`.

## Construction Decisions (resolves Open Questions)

| Decision | Choice | Notes |
| -------- | ------ | ----- |
| Crop expense/harvest delete | **Hard-delete** | Parity with cow milk/feeding & poultry egg/feeding |
| Crop expense/harvest update | Partial PATCH via `model_fields_set` | Same as cows/poultry |
| Archived crop cycle | Block expense/harvest **update/delete** | `409 CROP_CYCLE_ARCHIVED` |
| Cross-owner / miss | `404` | `CROP_EXPENSE_NOT_FOUND` / `HARVEST_NOT_FOUND` / cycle not found |
| Fertilizer stock UI API | **Cross-item list** `GET …/stock-updates?category=fertilizer` | All updates for items in fertilizer category; include item id/name |
| Fertilizer stock Action (PATCH/DELETE) | **Out of this bolt** | Inventory v1 uses compensating POST; FR-3 requires table + paging minimum |
| Ledger numeric totals | Keep `GET /ledger-entries/totals` | Unchanged contract |
| Ledger graph data | **New** `GET /ledger-entries/series` | Daily (default) buckets of income, expenses, net in `[from,to]` |
| Dashboard milk | Sum of milk `quantity` per bucket (owner’s cows) | Active + historical rows in range |
| Dashboard cow_production | Count of **non-archived cows** owned at bucket end (headcount snapshot) | Distinct from milk qty series |
| Dashboard egg_production | Sum of egg production `quantity` per bucket | Owner poultry groups |
| Dashboard hen_headcount | Sum of poultry group **bird/headcount** fields for non-archived groups (snapshot per bucket end) | Distinct from eggs; exact group field name confirmed at implement against model |
| Dashboard expenses_cost | Sum ledger **expense** `amount` in bucket | General ledger only (not crop-cycle expenses) |
| Dashboard income | Sum ledger **income** `amount` in bucket | General ledger only |
| Period grain | `day` \| `week` \| `month` \| `year` | Client default **week**; API accepts explicit `from`/`to` + `grain` |
| Future dates | Reject when `to` > farm-local **today** | `422 FUTURE_DATE_NOT_ALLOWED` |
| Farm timezone | Add optional `timezone` on farm settings; default **`Asia/Dhaka`** when null/unset | Matches BDT-first product; IANA string |
| Schema migration | Alembic only if `farm_settings.timezone` missing | No change to crop/inventory/ledger fact tables for mutations |
| ADR needed? | **No** — extends existing module patterns; Stage 3 skip expected | |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Crop expenses / harvests (extend)

| Endpoint | Method | Auth | Request | Response |
| -------- | ------ | ---- | ------- | -------- |
| `/api/v1/crop-cycles/{cycle_id}/expenses/{expense_id}` | PATCH | Owner | ExpenseUpdate (partial) | CropExpense |
| `/api/v1/crop-cycles/{cycle_id}/expenses/{expense_id}` | DELETE | Owner | — | `204` |
| `/api/v1/crop-cycles/{cycle_id}/harvests/{harvest_id}` | PATCH | Owner | HarvestUpdate (partial) | Harvest |
| `/api/v1/crop-cycles/{cycle_id}/harvests/{harvest_id}` | DELETE | Owner | — | `204` |

**ExpenseUpdate**: optional `spent_at`, `category`, `amount`, `note`  
**HarvestUpdate**: optional `harvested_at`, `quantity`, `unit`, `sale_amount`, `note`

Existing POST/GET list unchanged.

### Fertilizer-category stock updates (new list)

| Endpoint | Method | Auth | Request | Response |
| -------- | ------ | ---- | ------- | -------- |
| `/api/v1/inventory-stock-updates` | GET | Owner | `category` (required for fertilizer use: `fertilizer`), `limit` (default 10), `offset` | `{ items, meta }` newest first |

**StockUpdateListItem**: existing StockUpdate fields **plus** `inventory_item_id`, `item_name`, `item_unit` (and optionally `item_category`) for table display.

When `category=fertilizer`, only rows whose item category is fertilizer. Other categories allowed for reuse but clients for FR-3 always pass `fertilizer`.

### Ledger series (new) + existing totals

| Endpoint | Method | Auth | Request | Response |
| -------- | ------ | ---- | ------- | -------- |
| `/api/v1/ledger-entries/totals` | GET | Owner | `from`, `to` (required) | PeriodTotals (unchanged; includes `net`) |
| `/api/v1/ledger-entries/series` | GET | Owner | `from`, `to` (required), `grain?` (default `day`) | LedgerSeries |

Register `/series` and `/totals` before `/{entry_id}`.

**LedgerSeries**: `from`, `to`, `grain`, `points: [{ bucket_start, income, expenses, net }]`  
Empty range → `points: []` or zero-filled buckets (prefer **zero-filled** for continuous charts when grain is day/week; document choice at implement — recommend zero-fill within `[from,to]`).

Optional: reject future `to` on totals/series with same `FUTURE_DATE_NOT_ALLOWED` for consistency with dashboard (recommended **yes**).

### Dashboard aggregates (new)

| Endpoint | Method | Auth | Request | Response |
| -------- | ------ | ---- | ------- | -------- |
| `/api/v1/dashboard/aggregates` | GET | Owner | `from`, `to` (required), `grain` (required: day\|week\|month\|year) | DashboardAggregates |

**DashboardAggregates**:

```json
{
  "from": "YYYY-MM-DD",
  "to": "YYYY-MM-DD",
  "grain": "week",
  "timezone": "Asia/Dhaka",
  "series": {
    "egg_production": [{ "bucket_start": "...", "value": "0" }],
    "hen_headcount": [{ "bucket_start": "...", "value": "0" }],
    "milk": [{ "bucket_start": "...", "value": "0" }],
    "cow_production": [{ "bucket_start": "...", "value": "0" }],
    "expenses_cost": [{ "bucket_start": "...", "value": "0" }],
    "income": [{ "bucket_start": "...", "value": "0" }]
  }
}
```

Numeric `value` as decimal strings consistent with money/qty JSON elsewhere.

### Farm settings timezone (extend if missing)

| Endpoint | Change |
| -------- | ------ |
| `GET/PATCH /api/v1/farm-settings` | Include optional `timezone` (IANA); omit/null → treat as `Asia/Dhaka` |

## Data Persistence

| Table / model | Change | Notes |
| ------------- | ------ | ----- |
| `crop_expenses` / `harvests` | None | Hard-delete via session delete |
| `stock_updates` / `inventory_items` | None | Filter join on category |
| `ledger_entries` | None | Series query by `occurred_at` |
| milk / egg / poultry / cows | None | Read aggregates |
| `farm_settings` | Add `timezone` VARCHAR nullable if absent | Default application-side `Asia/Dhaka` |

### Migration

Alembic revision only when `timezone` column is missing on farm settings.

## Security Design

| Concern | Approach |
| ------- | -------- |
| Authentication | Existing JWT `get_current_owner` |
| Authorization | All queries/mutations filter `owner_id`; cross-owner → `404` |
| Archived writes | Crop cycle archived → `409` on expense/harvest PATCH/DELETE |
| Future dates | Server validates `to` ≤ today in farm TZ on dashboard (+ recommended on ledger series/totals) |
| Validation | Reuse crop/inventory/ledger domain validators; `422` envelope |

## NFR Implementation

| Requirement | Design Approach |
| ----------- | --------------- |
| Performance | Single SQL aggregates per series where possible; prefer p95 &lt; 3s for modest data; avoid N+1 per cow/group |
| Compatibility | Additive routes; existing create/list/totals unchanged |
| Reliability | Empty/zero-filled series; no 500 on sparse data |
| Contract-first | OpenAPI via FastAPI before web `033` / mobile `034` |

## Error Handling

| Error Type | HTTP | Code |
| ---------- | ---- | ---- |
| Validation | 422 | `VALIDATION_ERROR` |
| Future date | 422 | `FUTURE_DATE_NOT_ALLOWED` |
| Crop cycle archived | 409 | `CROP_CYCLE_ARCHIVED` |
| Expense not found | 404 | `CROP_EXPENSE_NOT_FOUND` |
| Harvest not found | 404 | `HARVEST_NOT_FOUND` |
| Unauthorized | 401 | existing auth codes |

## External Dependencies

| Service | Purpose | Integration |
| ------- | ------- | ----------- |
| PostgreSQL | Persist + aggregate | SQLAlchemy |
| None new | Charts are client-side | — |

## Story → Endpoint Mapping

| Story | Endpoints |
| ----- | --------- |
| 001-api-crop-expense-harvest-update-delete | PATCH/DELETE expenses & harvests |
| 002-api-fertilizer-stock-list | GET `/inventory-stock-updates?category=fertilizer` |
| 003-api-ledger-range-series | GET `/ledger-entries/series` (+ existing totals) |
| 004-api-dashboard-aggregates | GET `/dashboard/aggregates` + FarmClock / timezone |

## Out of Scope

- Soft-delete for crop/inventory history
- Stock update PATCH/DELETE
- Merging crop-cycle expenses into ledger dashboard series
- Web/mobile UI (bolts 033/034)
