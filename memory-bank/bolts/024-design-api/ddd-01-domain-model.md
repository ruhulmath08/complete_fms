---
unit: 001-design-api
bolt: 024-design-api
stage: model
status: complete
updated: "2026-11-12T07:46:46Z"
---

# Static Model - Design API (production table contracts)

## Bounded Context

**Design API (024)** extends the existing **Cows** bounded context and **cross-domain list paging** conventions so production-ready clients can:

1. Show a clear **Total** on Feeding (aligned with Milk: quantity × unit cost/price)
2. **Update** and **hard-delete** milk and feeding rows for table Action columns
3. Paginate **primary entity lists** (cows, poultry, crops, inventory, income/expenses) with page size **10** and `meta.total`

Owner-only scoping and cow soft-archive rules from intents `001`/`002` remain in force. This bolt does not invent new farm domains; it only extends contracts required by intent `003` FR-10 / stories 001–003.

## Domain Entities

| Entity                                                         | Properties                                                                                                    | Business Rules                                                                                                                                                                                                                                                               |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MilkProduction                                                 | id, cow_id, owner_id, produced_at, quantity, unit, price_per_unit, note?, timestamps                          | Eligibility unchanged (`milk` \| `both`). **Total** = `quantity × price_per_unit` (derived or returned). **Update** allowed fields; **hard-delete** removes the row. Writes blocked when cow is archived (same guard as add). Listing keeps page size default **10** + meta. |
| CowFeeding                                                     | id, cow_id, owner_id, fed_at, feed_name, quantity, unit, **unit_cost** (or price_per_unit), note?, timestamps | **unit_cost** required for new/updated rows so **Total** = `quantity × unit_cost` is unambiguous. Update/delete same ownership and archive guards as milk. Listing page size **10** + meta.                                                                                  |
| Cow (list)                                                     | Existing cow profile fields                                                                                   | Active/archived list must support `limit`/`offset` with **meta.total** for table UIs                                                                                                                                                                                         |
| PoultryGroup / CropCycle / InventoryItem / LedgerEntry (lists) | Existing domain fields                                                                                        | Each primary list endpoint must support paging with **meta.total** for page size 10; no new aggregates beyond list meta parity                                                                                                                                               |

## Value Objects

| Value Object | Properties           | Constraints                                                                              |
| ------------ | -------------------- | ---------------------------------------------------------------------------------------- |
| MoneyAmount  | amount               | Non-negative decimal/string money; used for price_per_unit, unit_cost, Total             |
| Quantity     | amount, unit         | amount ≥ 0 for display totals (zero → Total 0); unit non-empty on write                  |
| RowTotal     | amount               | `quantity × unit_price_or_cost`; always computable when both factors present             |
| PageRequest  | limit, offset        | Default/recommended `limit=10` for table surfaces; enforce max limit in technical design |
| PageMeta     | total, limit, offset | `total` = full matching count; enough for clients to paginate without loading all rows   |
| SubRecordId  | id (UUID/string)     | Identifies milk or feeding row within owner scope                                        |

## Aggregates

| Aggregate Root                              | Members                                                      | Invariants                                                                                                                                                                                                                                                            |
| ------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cow                                         | Cow profile; child MilkProduction; child CowFeeding          | Owner ownership immutable. Milk/feeding mutations only for owning owner. Archived cow: block create/update/delete of children; history still listable. Feeding rows always carry unit_cost after this bolt so Total is defined. Hard-delete of children is permanent. |
| Listable farm entities (per existing roots) | Poultry groups, crop cycles, inventory items, ledger entries | List queries remain owner-scoped; PageMeta.total reflects owner-visible set (including filters like include_archived where applicable)                                                                                                                                |

## Domain Events

| Event                  | Trigger                                | Payload                                      |
| ---------------------- | -------------------------------------- | -------------------------------------------- |
| MilkProductionUpdated  | Milk row updated                       | milk_id, cow_id, owner_id, changed_fields    |
| MilkProductionDeleted  | Milk row hard-deleted                  | milk_id, cow_id, owner_id                    |
| CowFeedingUpdated      | Feeding row updated                    | feeding_id, cow_id, owner_id, changed_fields |
| CowFeedingDeleted      | Feeding row hard-deleted               | feeding_id, cow_id, owner_id                 |
| CowFeedingTotalDefined | Feeding created/updated with unit_cost | feeding_id, total                            |

Persistent event bus not required; events document domain meaning for design/tests.

## Domain Services

| Service                              | Operations                                                                                             | Dependencies                                                 |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| MilkProductionService                | add (existing); **update**; **delete**; list_by_cow(PageRequest) → page                                | CowRepository, MilkProductionRepository, AuthorizationPolicy |
| CowFeedingService                    | add (with unit_cost); **update**; **delete**; list_by_cow(PageRequest) → page; compute/expose RowTotal | CowRepository, CowFeedingRepository, AuthorizationPolicy     |
| EntityListPagingService (conceptual) | Ensure cows/poultry/crops/inventory/ledger **list** accept PageRequest and return PageMeta             | Respective repositories                                      |

## Repository Interfaces

| Repository               | Entity         | Methods                                                                                                           |
| ------------------------ | -------------- | ----------------------------------------------------------------------------------------------------------------- |
| MilkProductionRepository | MilkProduction | save; get_by_id(owner_id, id); update; **delete**; list_by_cow(owner_id, cow_id, PageRequest) → (items, PageMeta) |
| CowFeedingRepository     | CowFeeding     | save; get_by_id(owner_id, id); update; **delete**; list_by_cow(owner_id, cow_id, PageRequest) → (items, PageMeta) |
| CowRepository            | Cow            | list_active / list (existing) with PageRequest → (items, PageMeta) if not already                                 |
| PoultryGroupRepository   | PoultryGroup   | list(owner_id, PageRequest) → (items, PageMeta)                                                                   |
| CropCycleRepository      | CropCycle      | list(owner_id, PageRequest) → (items, PageMeta)                                                                   |
| InventoryItemRepository  | InventoryItem  | list(owner_id, PageRequest) → (items, PageMeta)                                                                   |
| LedgerEntryRepository    | LedgerEntry    | list(owner_id, PageRequest, filters?) → (items, PageMeta)                                                         |

All queries/mutations filter by `owner_id`. Cross-owner access → reject (403/404 per API conventions).

## Ubiquitous Language

| Term                 | Definition                                                                        |
| -------------------- | --------------------------------------------------------------------------------- |
| Total (milk)         | Derived amount: quantity × price_per_unit                                         |
| Total (feeding)      | Derived amount: quantity × unit_cost                                              |
| unit_cost            | Price per unit of feed for a feeding row (required for Total)                     |
| Action Edit/Delete   | Client table actions backed by update/delete on milk/feeding sub-records          |
| Hard-delete          | Permanent removal of a milk/feeding row (default for this intent)                 |
| Page size 10         | Default page length for production data tables                                    |
| PageMeta.total       | Count of all matching rows for the current list filter, not just the current page |
| Archived write guard | Archived cows disallow mutating child milk/feeding rows                           |

## Story Coverage

| Story                                 | Domain coverage                                                                         |
| ------------------------------------- | --------------------------------------------------------------------------------------- |
| 001-api-feeding-total-and-list-meta   | CowFeeding.unit_cost, RowTotal, PageMeta on feeding/milk lists                          |
| 002-api-milk-feeding-update-delete    | update/delete on MilkProduction and CowFeeding; ownership + archive guards; hard-delete |
| 003-api-entity-list-pagination-parity | PageRequest/PageMeta on cows, poultry, crops, inventory, ledger lists                   |

## Decisions Locked in This Model

| Topic                 | Decision                                                            |
| --------------------- | ------------------------------------------------------------------- |
| Feeding Total         | `quantity × unit_cost`; add `unit_cost` to feeding model if missing |
| Milk Total            | Remains `quantity × price_per_unit`                                 |
| Delete semantics      | Hard-delete for milk/feeding sub-records                            |
| Archived cow          | Block update/delete of children (same as block add)                 |
| Entity list page size | Clients use limit=10; APIs expose meta.total                        |

## Changes vs Intent 002 Design API Model

| Topic                  | Intent 002 (019)          | This bolt (024)                           |
| ---------------------- | ------------------------- | ----------------------------------------- |
| Feeding fields         | No unit_cost / Total      | unit_cost required for Total              |
| Milk/feeding mutations | Add + list only           | Add + list + **update** + **delete**      |
| Pagination             | Milk/feeding page size 10 | Also primary **entity lists** meta parity |
| Tag / cow image        | Delivered in 019          | Unchanged; out of scope here              |
