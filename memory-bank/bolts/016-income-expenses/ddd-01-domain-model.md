---
unit: 006-income-expenses
bolt: 016-income-expenses
stage: model
status: complete
updated: 2026-11-09T13:13:23Z
---

# Static Model - Income and Expenses

## Bounded Context

**Income & Expenses** owns the owner’s **general ledger entries** (standalone income or expense lines) and **period totals** over a selected date range. All data is scoped to the single signed-in **Owner** from Platform & Auth.

Does not own cows, poultry, crops, or inventory. **Crop-cycle expenses and harvest sale income stay in the Crops context** (FR-9 / FR-11): this context never imports or aggregates `CropExpense` / harvest sales. Totals here sum only general ledger entries. UI/docs should steer crop planting costs to the Crops module so they are not double-entered as general expenses.

## Domain Entities

| Entity      | Properties                                                                                                                                | Business Rules                                                                                                                                                                                                                                                                                                        |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LedgerEntry | id, owner_id, entry_type (income\|expense), occurred_at, category, amount, unit?, total_price, note?, is_archived, created_at, updated_at | Belongs to one owner. Type, date, category required. Soft-archive; default lists exclude archived. Writes blocked when archived (ADR-004). `amount` and `total_price` money semantics finalized in Technical Design (see Open Questions). Period totals use the chosen money field for non-archived entries in range. |

## Value Objects

| Value Object  | Properties                             | Constraints                                                                                                |
| ------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| EntryType     | value                                  | `income` or `expense`                                                                                      |
| EntryCategory | value                                  | Fixed enum set (exact values + whether income/expense share one set confirmed in design)                   |
| MoneyAmount   | amount                                 | Positive for the monetary field used in totals                                                             |
| QuantityHint  | amount?                                | Optional associated quantity if design keeps `amount` as quantity and `total_price` as money               |
| UnitLabel     | value?                                 | Optional free-text unit when a quantity/context is recorded                                                |
| EntryDate     | occurred_at                            | Required calendar date; used for list-by-date and period filters                                           |
| ArchiveFlag   | is_archived                            | Soft retire; archived hidden from default active lists                                                     |
| PeriodTotals  | from, to, total_income, total_expenses | Derived read model: sum money for income vs expense entries in `[from, to]` (inclusive); archived excluded |

## Aggregates

| Aggregate Root | Members                         | Invariants                                                                                                                  |
| -------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| LedgerEntry    | Single entry profile            | Owner immutable. Archive blocks further updates (ADR-004). No hard delete in v1. No link to crop cycles or inventory items. |
| PeriodTotals   | Read model only (not persisted) | Computed from LedgerEntry queries; never includes Crops-module expenses/harvests                                            |

## Domain Events

| Event               | Trigger              | Payload                                      |
| ------------------- | -------------------- | -------------------------------------------- |
| LedgerEntryRecorded | Entry created        | entry_id, owner_id, entry_type, amount/total |
| LedgerEntryUpdated  | Entry fields changed | entry_id, changed_fields                     |
| LedgerEntryArchived | Entry archived       | entry_id, archived_at                        |
| PeriodTotalsViewed  | Totals requested     | owner_id, from, to (optional audit)          |

## Domain Services

| Service             | Operations                                                | Dependencies                                       |
| ------------------- | --------------------------------------------------------- | -------------------------------------------------- |
| LedgerEntryService  | create, get, list_active (date filters?), update, archive | LedgerEntryRepository, owner auth                  |
| PeriodTotalsService | get_totals(owner_id, from, to)                            | LedgerEntryRepository; sums by entry_type in range |

## Repository Interfaces

| Repository            | Entity      | Methods                                                                                                                                 |
| --------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| LedgerEntryRepository | LedgerEntry | save; get_by_id(owner_id, id); list_active(owner_id, from?, to?, paging?); update; archive; sum_by_type(owner_id, entry_type, from, to) |

All queries filter by `owner_id`.

## Ubiquitous Language

| Term                 | Definition                                                                                        |
| -------------------- | ------------------------------------------------------------------------------------------------- |
| Ledger entry         | One general income or expense line (not crop-cycle expense, not inventory stock money)            |
| Income               | Money received recorded in the general ledger                                                     |
| Expense              | Money spent recorded in the general ledger                                                        |
| Period totals        | Sum of income amounts and sum of expense amounts for a selected inclusive date range              |
| Amount / total price | Monetary (and optional quantity) fields on an entry — exact semantics decided in Technical Design |
| Archive              | Soft-retire an entry from active lists without hard delete                                        |

## Story Coverage

| Story                       | Domain coverage                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------------------------ |
| 001-api-income-and-expenses | LedgerEntry CRUD/archive; period totals by date range; isolation from Crops expenses (no double-count) |

## Open Questions Deferred to Technical Design

- **`amount` vs `total_price`** → propose **`amount` as the required monetary value (> 0)** used in period totals; **`unit` optional** free string; **`total_price` returned equal to `amount` on read** for FR/client parity (no separate persisted calculation in v1). Alternative: treat `amount` as quantity and `total_price` as money — reject unless product needs quantity on every line
- **Category enum** → propose shared set with type discriminator, e.g. `labour`, `feed_or_supplies`, `utilities`, `transport`, `equipment`, `livestock_sale`, `product_sale`, `subsidy`, `other` (exact list in design); income vs expense may share labels
- **Default list filter** → propose active-only; optional `include_archived`; optional `from`/`to` on list matching totals range
- **Edit/delete of entries** → propose full update of non-archived fields; no hard delete; archive only
- **Paging** → propose limit 20 default, max 100 (match prior modules)
- **Totals endpoint shape** → propose `GET .../ledger-entries/totals?from=&to=` returning `total_income`, `total_expenses` (and optional `net`)
- **Date inclusivity** → propose inclusive `[from, to]` on `occurred_at` date
- **Empty range / missing dates** → propose 400 validation if `from`/`to` missing or `from` > `to`
- **Resource naming** → propose `/api/v1/ledger-entries` (or `/income-expense-entries`); confirm in design

## Relevant Prior Decisions

- **ADR-004**: Soft-archive + write block; no unarchive in v1 — apply to LedgerEntry
- **ADR-002**: Sync SQLAlchemy persistence (implementation stage)
- **Crops FR-9 / ADR context**: Crop expenses remain in Crops module only — no cross-aggregate totals here
