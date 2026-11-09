---
unit: 002-cows
bolt: 004-cows
stage: model
status: complete
updated: 2026-11-09T10:07:35Z
---

# Static Model - Cows

## Bounded Context

**Cows** owns individual cow identity/lifecycle (active vs archived), milk production entries for milk-eligible cows, and feeding entries for any cow. All data is scoped to the single signed-in **Owner** established by Platform & Auth.

Does not own poultry, crops, inventory, or general income/expenses.

## Domain Entities

| Entity | Properties | Business Rules |
|--------|------------|----------------|
| Cow | id, owner_id, tag_number, name?, breed?, date_of_birth?, purpose (milk\|meat\|both), gender, color?, weight?, age?, acquired_by (purchased\|born_on_farm), purchase_date?, purchase_price?, notes?, is_archived, created_at, updated_at | Belongs to one owner. Tag number required. Purpose and gender required. Purchase date/price required only when `acquired_by=purchased`; otherwise those fields must be absent/null. Soft-archive via `is_archived`; active lists exclude archived. Meat-only cows do not require milk entries. |
| MilkProduction | id, cow_id, owner_id, produced_at, quantity, unit, price_per_unit, note?, created_at, updated_at | Allowed only when cow purpose is `milk` or `both`. Quantity > 0. Unit required (suggested units from platform config; free-text allowed). Price per unit ≥ 0. |
| CowFeeding | id, cow_id, owner_id, fed_at, feed_name, quantity, unit, note?, created_at, updated_at | Allowed for any non-deleted/archived cow still owned. Quantity > 0. Feed name and unit required. |

## Value Objects

| Value Object | Properties | Constraints |
|--------------|------------|-------------|
| CowPurpose | value | One of `milk`, `meat`, `both` |
| Gender | value | Required non-empty (e.g. male/female/unknown as product allows; store as string with validation set in design) |
| AcquisitionSource | value | `purchased` or `born_on_farm` |
| MoneyAmount | amount | Non-negative decimal for purchase_price / price_per_unit |
| Quantity | amount, unit | amount > 0; unit non-empty string |
| TagNumber | value | Required; unique among **active** cows per owner; may be reused after the previous holder is archived |
| ArchiveFlag | is_archived | Soft delete; archived cows hidden from default active lists |

## Aggregates

| Aggregate Root | Members | Invariants |
|----------------|---------|------------|
| Cow | Cow profile fields; child MilkProduction and CowFeeding collections (consistency boundary for milk eligibility) | Owner ownership immutable for v1. Purchase fields only when purchased. Milk entries rejected if purpose is `meat`. Archiving cow does not delete history; milk/feeding writes may be blocked on archived cows (design choice: **block new entries on archived cows**; history remains readable by id). |

## Domain Events

| Event | Trigger | Payload |
|-------|---------|---------|
| CowRegistered | Cow created | cow_id, owner_id, tag_number, purpose |
| CowUpdated | Cow fields changed | cow_id, changed_fields |
| CowArchived | Cow archived | cow_id, archived_at |
| MilkProductionRecorded | Milk entry added | cow_id, entry_id, produced_at, quantity, unit |
| CowFeedingRecorded | Feeding entry added | cow_id, entry_id, fed_at, feed_name, quantity, unit |

## Domain Services

| Service | Operations | Dependencies |
|---------|------------|--------------|
| CowService | create, get, list_active, update, archive | CowRepository, AuthorizationPolicy (owner) |
| MilkProductionService | add, list_by_cow | CowRepository, MilkProductionRepository; enforces purpose eligibility |
| CowFeedingService | add, list_by_cow | CowRepository, CowFeedingRepository |

## Repository Interfaces

| Repository | Entity | Methods |
|------------|--------|---------|
| CowRepository | Cow | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive |
| MilkProductionRepository | MilkProduction | save; list_by_cow(owner_id, cow_id, paging?) |
| CowFeedingRepository | CowFeeding | save; list_by_cow(owner_id, cow_id, paging?) |

All queries must filter by `owner_id` (owner-only access).

## Ubiquitous Language

| Term | Definition |
|------|------------|
| Cow | Individual livestock record for milk and/or meat |
| Purpose | Whether the cow is kept for milk, meat, or both |
| Archive | Soft-retire a cow from active lists without hard delete |
| Milk production | Timestamped milk yield entry for milk-eligible cows |
| Feeding | Timestamped feed intake entry for any cow |
| Acquired by | How the cow entered the farm: purchased or born on farm |
| Active list | Default listing of non-archived cows for the owner |

## Story Coverage

| Story | Domain coverage |
|-------|-----------------|
| 001-api-cow-records | Cow aggregate, archive, purchase field rules, owner scoping |
| 002-api-cow-milk-and-feeding | MilkProduction eligibility, CowFeeding for any cow, list-by-cow |

## Open Questions Deferred to Technical Design

- Exact gender enum values → resolved in design: `female` \| `male` \| `unknown`
- Tag uniqueness → resolved: unique among **active** cows per owner; reusable after archive
- Default list paging limits for milk/feeding history → resolved: limit 20 default, max 100
- Whether archived cow detail remains GET-able → resolved: yes; writes blocked
