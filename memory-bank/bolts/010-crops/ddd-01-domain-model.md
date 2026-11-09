---
unit: 004-crops
bolt: 010-crops
stage: model
status: complete
updated: 2026-11-09T11:59:40Z
---

# Static Model - Crops

## Bounded Context

**Crops** owns the owner’s **crop name catalog**, **crop cycles** (planted seasons/plots referencing a catalog name), **cycle expenses**, **harvests**, and a **simple cycle summary** (expense total, sale income, income − expenses). All data is scoped to the single signed-in **Owner** from Platform & Auth.

Does not own cows, poultry, inventory, or general income/expenses. Crop-cycle expenses stay in this context only (FR-11: not double-counted as general expenses).

## Domain Entities

| Entity      | Properties                                                                                                                              | Business Rules                                                                                                                                                                                                                                                          |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CropName    | id, owner_id, name, notes?, is_archived, created_at, updated_at                                                                         | Belongs to one owner. Display name required. Soft-archive; default lists exclude archived. Cycles must reference an existing catalog id (not free text).                                                                                                                |
| CropCycle   | id, owner_id, crop_name_id, plot_name?, area?, location?, planted_at, expected_harvest_at?, notes?, is_archived, created_at, updated_at | Belongs to one owner. `crop_name_id` required and must belong to same owner; creating/updating a cycle against an **archived** crop name is rejected. Planted date required. Soft-archive; default lists exclude archived. Archiving does not delete expenses/harvests. |
| CropExpense | id, crop_cycle_id, owner_id, spent_at, category, amount, note?, created_at, updated_at                                                  | Allowed only for owned non-archived cycles. Category one of fixed set. Amount > 0.                                                                                                                                                                                      |
| Harvest     | id, crop_cycle_id, owner_id, harvested_at, quantity, unit, sale_amount?, note?, created_at, updated_at                                  | Allowed only for owned non-archived cycles. Quantity > 0; unit required. Sale amount optional; if present ≥ 0.                                                                                                                                                          |

## Value Objects

| Value Object    | Properties                                | Constraints                                                                                      |
| --------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------ |
| CropNameLabel   | value                                     | Required non-empty; uniqueness among **active** names per owner (design confirms)                |
| ExpenseCategory | value                                     | `labour`, `fertilizers`, `pesticides_and_chemicals`, `seeds`, `irrigation`, `equipment`, `other` |
| MoneyAmount     | amount                                    | Positive for expense amount; non-negative for sale_amount / area                                 |
| Quantity        | amount, unit                              | amount > 0; unit non-empty                                                                       |
| Area            | value                                     | Optional; ≥ 0 when present                                                                       |
| ArchiveFlag     | is_archived                               | Soft retire; archived hidden from default active lists                                           |
| CycleSummary    | total_expenses, total_sale_income, result | Derived: sum(expenses.amount), sum(harvest.sale_amount null-as-0), income − expenses             |

## Aggregates

| Aggregate Root | Members                                                                                  | Invariants                                                                                                                                                                          |
| -------------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CropName       | Catalog entry                                                                            | Owner immutable. Active name unique per owner. Archive hides from pickers; does not cascade-delete cycles.                                                                          |
| CropCycle      | Cycle profile + child CropExpense and Harvest collections; summary derived from children | Owner immutable. Must reference valid same-owner CropName. New expenses/harvests/writes blocked when cycle archived (ADR-004). Summary is read-model only (not a persisted ledger). |

## Domain Events

| Event               | Trigger              | Payload                                            |
| ------------------- | -------------------- | -------------------------------------------------- |
| CropNameRegistered  | Name created         | crop_name_id, owner_id, name                       |
| CropNameUpdated     | Name fields changed  | crop_name_id, changed_fields                       |
| CropNameArchived    | Name archived        | crop_name_id, archived_at                          |
| CropCycleOpened     | Cycle created        | cycle_id, owner_id, crop_name_id                   |
| CropCycleUpdated    | Cycle fields changed | cycle_id, changed_fields                           |
| CropCycleArchived   | Cycle archived       | cycle_id, archived_at                              |
| CropExpenseRecorded | Expense added        | cycle_id, expense_id, category, amount             |
| HarvestRecorded     | Harvest added        | cycle_id, harvest_id, quantity, unit, sale_amount? |

## Domain Services

| Service            | Operations                                             | Dependencies                                                                 |
| ------------------ | ------------------------------------------------------ | ---------------------------------------------------------------------------- |
| CropNameService    | create, get, list_active, update, archive              | CropNameRepository, owner auth                                               |
| CropCycleService   | create, get, list_active, update, archive, get_summary | CropCycleRepository, CropNameRepository; enforces name not archived on write |
| CropExpenseService | add, list_by_cycle                                     | CropCycleRepository, CropExpenseRepository                                   |
| HarvestService     | add, list_by_cycle                                     | CropCycleRepository, HarvestRepository                                       |

## Repository Interfaces

| Repository            | Entity      | Methods                                                                                                             |
| --------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------- |
| CropNameRepository    | CropName    | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive; find_active_by_name(owner_id, name) |
| CropCycleRepository   | CropCycle   | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive                                      |
| CropExpenseRepository | CropExpense | save; list_by_cycle(owner_id, cycle_id, paging?); sum_amount(owner_id, cycle_id)                                    |
| HarvestRepository     | Harvest     | save; list_by_cycle(owner_id, cycle_id, paging?); sum_sale_amount(owner_id, cycle_id)                               |

All queries filter by `owner_id`. Child expense/harvest tables carry denormalized `owner_id` (ADR-005).

## Ubiquitous Language

| Term          | Definition                                                                                         |
| ------------- | -------------------------------------------------------------------------------------------------- |
| Crop name     | Catalog label the owner manages (e.g. rice, tomato); not free text on cycles                       |
| Crop cycle    | One planting/season/plot instance referencing a crop name                                          |
| Crop expense  | Categorized cost attached to a cycle                                                               |
| Harvest       | Yield entry for a cycle; optional sale amount                                                      |
| Cycle summary | Total expenses, total sale income, and simple result (income − expenses) from entered records only |
| Archive       | Soft-retire a name or cycle from active lists without hard delete                                  |

## Story Coverage

| Story                                  | Domain coverage                                                        |
| -------------------------------------- | ---------------------------------------------------------------------- |
| 001-api-crop-names-and-cycles          | CropName catalog; CropCycle requires catalog id; CRUD/archive for both |
| 002-api-crop-expenses-harvests-summary | Expenses by category; harvests; cycle summary totals                   |

## Open Questions Deferred to Technical Design

- Active crop-name uniqueness per owner → propose unique among active (partial unique index), reuse name after archive
- Whether cycles may keep referencing a crop name after that name is archived → propose yes for existing; reject new/updated cycles selecting archived names
- Area unit (acres/hectares/free string) → propose optional numeric `area` only (no unit enum in v1) or optional unit string
- Summary endpoint shape → propose `GET .../cycles/{id}/summary` computed on read
- Paging defaults → propose limit 20 default, max 100 (match cows/poultry)
- Expense/harvest edit/delete → propose add+list only in v1 (no PATCH/DELETE) unless design expands; FR says “add and review”

## Relevant Prior Decisions

- **ADR-004**: Soft-archive + write block; no unarchive in v1 — apply to CropName and CropCycle
- **ADR-005**: Denormalize `owner_id` on expense/harvest child tables
- **ADR-006**: Pattern for active-only uniqueness — candidate for active crop names (confirm in design/ADR if needed)
- **ADR-002**: Sync SQLAlchemy persistence (implementation stage)
