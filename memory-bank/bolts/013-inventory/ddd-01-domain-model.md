---
unit: 005-inventory
bolt: 013-inventory
stage: model
status: complete
updated: 2026-11-09T12:37:00Z
---

# Static Model - Inventory

## Bounded Context

**Inventory** owns the owner’s **inventory items** (stocked supplies) and **stock updates** (add/use quantity changes) with a hard **no-negative-stock** rule. Displayed quantity always reflects the item’s current quantity after applied updates. All data is scoped to the single signed-in **Owner** from Platform & Auth.

Does not own cows, poultry, crops, or general income/expenses. Inventory is a standalone stock ledger for farm supplies (not livestock bird/cow counts, not crop harvests).

## Domain Entities

| Entity        | Properties                                                                                                             | Business Rules                                                                                                                                                                                                                                                                |
| ------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| InventoryItem | id, owner_id, name, category, quantity, unit, price_per_unit, note?, is_archived, created_at, updated_at               | Belongs to one owner. Name, category, unit required. Quantity ≥ 0. Price per unit ≥ 0. Soft-archive; default lists exclude archived. Archiving does not delete stock-update history. Writes (profile update, new stock updates) blocked when archived (ADR-004).              |
| StockUpdate   | id, inventory_item_id, owner_id, occurred_at, change_type (add\|use), quantity_change, reason?, created_at, updated_at | Allowed only for owned **non-archived** items. `quantity_change` > 0. `add` increases item quantity; `use` decreases it. A `use` that would leave quantity &lt; 0 is rejected with a stable domain error. Does not itself store signed delta; direction is via `change_type`. |

`total_price` is a **derived read concern** (quantity × price_per_unit) unless Technical Design chooses to persist it — see Open Questions.

## Value Objects

| Value Object      | Properties  | Constraints                                                                 |
| ----------------- | ----------- | --------------------------------------------------------------------------- |
| ItemName          | value       | Required non-empty; identity is `id` (uniqueness policy deferred to design) |
| InventoryCategory | value       | Fixed enum set (exact values confirmed in design)                           |
| StockQuantity     | amount      | ≥ 0 on item; change amount > 0 on StockUpdate                               |
| UnitLabel         | value       | Required non-empty string                                                   |
| MoneyAmount       | amount      | Non-negative for price_per_unit; total_price derived ≥ 0                    |
| StockChangeType   | value       | `add` or `use`                                                              |
| ArchiveFlag       | is_archived | Soft retire; archived items hidden from default active lists                |
| ItemTotalPrice    | amount      | Derived: quantity × price_per_unit (unless design stores/refreshes)         |

## Aggregates

| Aggregate Root | Members                                                | Invariants                                                                                                                                                                                                 |
| -------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| InventoryItem  | Item profile + current quantity; child StockUpdate log | Owner immutable. Quantity never negative. Stock updates apply atomically to quantity. Archive blocks further item writes and new stock updates; history remains GET-able. No hard delete of updates in v1. |

## Domain Events

| Event                   | Trigger                 | Payload                                                             |
| ----------------------- | ----------------------- | ------------------------------------------------------------------- |
| InventoryItemRegistered | Item created            | item_id, owner_id, name, category, quantity, unit                   |
| InventoryItemUpdated    | Item fields changed     | item_id, changed_fields                                             |
| InventoryItemArchived   | Item archived           | item_id, archived_at                                                |
| StockAdded              | Stock update with add   | item_id, update_id, quantity_change, quantity_after                 |
| StockUsed               | Stock update with use   | item_id, update_id, quantity_change, quantity_after                 |
| StockUpdateRejected     | Use would go below zero | item_id, attempted_change, quantity_before (for audit/logging only) |

## Domain Services

| Service              | Operations                                | Dependencies                                                                              |
| -------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------- |
| InventoryItemService | create, get, list_active, update, archive | InventoryItemRepository, owner auth                                                       |
| StockUpdateService   | add (apply change), list_by_item          | InventoryItemRepository, StockUpdateRepository; enforces non-archived + no-negative-stock |

## Repository Interfaces

| Repository              | Entity        | Methods                                                                        |
| ----------------------- | ------------- | ------------------------------------------------------------------------------ |
| InventoryItemRepository | InventoryItem | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive |
| StockUpdateRepository   | StockUpdate   | save; list_by_item(owner_id, item_id, paging?)                                 |

All queries filter by `owner_id`. Child stock-update table carries denormalized `owner_id` (ADR-005).

## Ubiquitous Language

| Term           | Definition                                                                |
| -------------- | ------------------------------------------------------------------------- |
| Inventory item | Named supply/stock record with current quantity and pricing               |
| Stock update   | Timestamped add or use that adjusts item quantity                         |
| Add            | Increase quantity by a positive change amount                             |
| Use            | Decrease quantity by a positive change amount (rejected if below zero)    |
| Quantity       | Current on-hand amount shown to the owner after all applied updates       |
| Total price    | Monetary extension of quantity × price per unit (derivation vs store TBD) |
| Archive        | Soft-retire an item from active lists without hard delete                 |

## Story Coverage

| Story                       | Domain coverage                                                                                          |
| --------------------------- | -------------------------------------------------------------------------------------------------------- |
| 001-api-inventory-and-stock | InventoryItem CRUD/archive; StockUpdate add/use; quantity reflection; reject negative resulting quantity |

## Open Questions Deferred to Technical Design

- **Active item-name uniqueness** → propose **not unique** (identity is `id`, like poultry groups); confirm in design
- **Category enum values** → propose fixed set (e.g. `feed`, `fertilizer`, `pesticide`, `seed`, `medicine`, `equipment`, `fuel`, `other`) or free string; confirm in design
- **`total_price` stored vs computed** → propose **computed on read** as `quantity × price_per_unit`; optionally omit persisted column
- **Initial quantity** → propose set on create; subsequent changes only via StockUpdate (no silent PATCH of quantity without a ledger entry — or allow admin quantity PATCH? propose **no direct quantity PATCH**; quantity changes only via stock updates + create initial)
- **Whether create writes an opening StockUpdate** → propose optional: create sets quantity without a child row; stock log starts at first explicit add/use
- **Edit/delete of stock updates** → propose **add + list only** in v1 (no reverse/amend); correcting stock requires a compensating update
- **Paging defaults** → propose limit 20 default, max 100 (match prior modules)
- **Archived GET** → propose allowed; writes blocked (`INVENTORY_ITEM_ARCHIVED`)
- **Error code for negative stock** → propose `INSUFFICIENT_STOCK` (409) with remaining quantity in message/details

## Relevant Prior Decisions

- **ADR-004**: Soft-archive + write block; no unarchive in v1 — apply to InventoryItem
- **ADR-005**: Denormalize `owner_id` on StockUpdate child table
- **ADR-002**: Sync SQLAlchemy persistence (implementation stage)
