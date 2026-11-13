---
unit: 001-ops-calc-api
bolt: 032-ops-calc-api
stage: domain-model
status: complete
updated: '2026-11-13T07:05:00Z'
---

# Domain Model - 032-ops-calc-api

## Bounded Context

**Ops / Calculations API** spans four cooperating contexts already owned by the farm product, extended only as needed for intent `005`:

1. **Crops** — mutate `CropExpense` and `Harvest` history under a `CropCycle`
2. **Inventory** — list (and optionally mutate) `StockUpdate` rows for items in the **fertilizer** category
3. **Income & Expenses** — expose ledger **period totals** plus a **time series** of income / expenses / net for graphing
4. **Dashboard Analytics** — read-model aggregates across cows, poultry, and ledger for a selected period, with **farm-local-timezone** date bounds

Does not reopen soft-delete policies of ledger archive; crop/inventory history deletes in this bolt are **hard-delete** (parity with cow milk/feeding and poultry egg/feeding).

## Domain Entities

| Entity | Properties | Business Rules |
| ------ | ---------- | -------------- |
| CropCycle | id, owner_id, is_archived, … | Ownership + archive gate mutations on child expenses/harvests |
| CropExpense | id, cycle_id, spent_at, category, amount, note? | Belongs to owned cycle; hard-deletable; update allowed fields only when cycle active |
| Harvest | id, cycle_id, harvested_at, quantity, unit, sale_amount?, note? | Belongs to owned cycle; hard-deletable; update when cycle active |
| InventoryItem | id, owner_id, category, … | Category includes `fertilizer`; ownership scopes stock history |
| StockUpdate | id, item_id, occurred_at, quantity_change, reason?, … | Listed for fertilizer-category items; optional update/delete only if Action requires |
| LedgerEntry | id, owner_id, entry_type, occurred_at, amount/total_price, is_archived, … | Soft-archive unchanged; series/totals exclude archived |
| FarmSettings | owner_id, currency_code, timezone? | Supplies farm local TZ for “today” / period bounds (default if unset decided in design) |
| Cow / MilkProduction | production history | Source for milk and cow-production dashboard series |
| PoultryGroup / EggProduction | eggs + headcount context | Source for egg production and hen headcount series |

## Value Objects

| Value Object | Properties | Constraints |
| ------------ | ---------- | ----------- |
| InventoryCategory | value | Includes `fertilizer`; fertilizer stock list filters on this |
| MoneyAmount | amount | Non-negative money used in ledger totals/series and dashboard income/expense |
| DateRange | from, to | Inclusive calendar dates; `to` must not be after farm-local “today” for aggregates |
| PeriodGrain | day \| week \| month \| year | Dashboard bucket size; default client grain is **week** |
| FarmTimezone | IANA/offset id | Defines local calendar day for future-date rejection and “this week” |
| LedgerSeriesPoint | occurred_on, income, expenses, net | Point or bucket for graph; net = income − expenses |
| DashboardSeries | name, points[] | Named series: egg_production, hen_headcount, milk, cow_production, expenses_cost, income |
| PeriodTotals | from, to, total_income, total_expenses, net? | Existing ledger totals; net may be derived |

## Aggregates

| Aggregate Root | Members | Invariants |
| -------------- | ------- | ---------- |
| CropCycle | CropExpense*, Harvest* | Owner immutable; archived cycle blocks expense/harvest update/delete; hard-delete removes child row |
| InventoryItem | StockUpdate* | Owner immutable; fertilizer list includes only updates whose item.category = fertilizer |
| LedgerEntry | Single entry | Soft-archive remains; period series/totals ignore archived |
| DashboardSnapshot | Read model only | Computed per owner + DateRange + PeriodGrain; never persists production rows |
| FarmSettings | Single settings row | Timezone (or documented default) is source of “today” |

## Domain Events

| Event | Trigger | Payload |
| ----- | ------- | ------- |
| CropExpenseUpdated / Deleted | Expense PATCH/DELETE | expense_id, cycle_id, owner_id |
| HarvestUpdated / Deleted | Harvest PATCH/DELETE | harvest_id, cycle_id, owner_id |
| FertilizerStockListed | Fertilizer stock list queried | owner_id, paging |
| LedgerSeriesViewed | Series/totals for graph | owner_id, from, to |
| DashboardAggregatesViewed | Dashboard aggregates requested | owner_id, grain, from, to |
| FutureDateRejected | Aggregate/list end after farm-local today | owner_id, to, today_local |

## Domain Services

| Service | Operations | Dependencies |
| ------- | ---------- | ------------ |
| CropHistoryMutationService | update/delete expense; update/delete harvest | CropCycle repository, ownership/archive guards |
| FertilizerStockQueryService | list stock updates for fertilizer-category items (paged) | InventoryItem + StockUpdate repositories |
| LedgerSeriesService | get_totals; get_series(from, to, grain?) | LedgerEntry repository |
| DashboardAggregateService | get_aggregates(grain, from, to) → six series | Cows/poultry/ledger read models; FarmTimezone |
| FarmClock | today_local(); assert_not_future(to) | FarmSettings timezone |

## Repository Interfaces

| Repository | Entity | Methods |
| ---------- | ------ | ------- |
| CropExpenseRepository | CropExpense | get; update; delete (hard); list by cycle |
| HarvestRepository | Harvest | get; update; delete (hard); list by cycle |
| StockUpdateRepository | StockUpdate | list_by_owner_and_category(fertilizer, paging); optional update/delete |
| LedgerEntryRepository | LedgerEntry | sum_by_type; series_points(owner_id, from, to, grain?) |
| ProductionReadRepository | Milk/Egg/Poultry/Cow | aggregate_for_dashboard(owner_id, from, to, grain) |
| FarmSettingsRepository | FarmSettings | get_timezone(owner_id) |

All mutating/query paths filter by `owner_id`.

## Ubiquitous Language

| Term | Definition |
| ---- | ---------- |
| Hard-delete | Permanent removal of a history row (expense, harvest, optionally stock update) |
| Fertilizer-category stock | All stock updates for inventory items whose category is fertilizer |
| Ledger series | Time-ordered income, expenses, and net suitable for graphing a date range |
| Period totals | Sum income and expenses (and derived net) for a range — kept alongside the graph |
| Dashboard aggregates | Period-bucketed egg production, hen headcount, milk, cow production, expenses/cost, income |
| Farm local today | Calendar date “now” in the farm’s timezone; end bounds after this are invalid |
| This week | Default dashboard period: farm-local week containing today |
| Cow production | Distinct dashboard series from milk — exact metric (e.g. headcount vs output) finalized in Technical Design |
| Hen headcount | Distinct from egg production; derived from poultry group headcount over the period |

## Story Coverage

| Story | Domain coverage |
| ----- | --------------- |
| 001-api-crop-expense-harvest-update-delete | CropCycle + CropExpense/Harvest mutations, hard-delete, archive/owner guards |
| 002-api-fertilizer-stock-list | InventoryItem category filter + StockUpdate list |
| 003-api-ledger-range-series | PeriodTotals + LedgerSeriesPoint |
| 004-api-dashboard-aggregates | DashboardSeries + FarmClock future-date rejection |

## Open Questions (for Technical Design)

1. Exact **cow production** metric vs **milk** (quantity vs headcount vs other)
2. **Farm timezone** field: already on FarmSettings or default (e.g. `Asia/Dhaka`) when unset
3. Whether fertilizer stock **Action** (PATCH/DELETE) is required in this bolt or list-only for FR-3
4. Ledger series grain (daily vs match dashboard grain) when only a free date range is applied

## Out of Scope

- Soft-delete for crop/inventory history
- Web/mobile UI
- Forecasting / multi-farm analytics
- Double-counting crop-cycle expenses inside general ledger dashboard income/expense (ledger series stays general-ledger-only; crop money stays in crops context unless design explicitly merges — prefer separate expenses/cost series sourced from ledger + documented production costs rule in design)
