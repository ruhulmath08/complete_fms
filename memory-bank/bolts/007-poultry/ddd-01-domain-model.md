---
unit: 003-poultry
bolt: 007-poultry
stage: model
status: complete
updated: 2026-11-09T11:22:54Z
---

# Static Model - Poultry

## Bounded Context

**Poultry** owns poultry **groups** (flocks/batches by type), bird-count updates, group feeding entries, and egg production entries for egg-eligible types. All data is scoped to the single signed-in **Owner** from Platform & Auth.

Does not own cows, crops, inventory, or general income/expenses.

## Domain Entities

| Entity         | Properties                                                                                                                                                                                                      | Business Rules                                                                                                                                                                                                                                                      |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PoultryGroup   | id, owner_id, poultry_type (broiler\|duck\|layer\|local), name, bird_count, date_acquired?, acquired_by (purchased\|born_on_farm), purchase_date?, purchase_price?, notes?, is_archived, created_at, updated_at | Belongs to one owner. Type and name required. Bird count ≥ 0 (integer). Purchase date/price required only when `acquired_by=purchased`; otherwise null/absent. Soft-archive via `is_archived`; default lists exclude archived. Broilers do not require egg entries. |
| PoultryFeeding | id, poultry_group_id, owner_id, fed_at, feed_name, quantity, unit, note?, created_at, updated_at                                                                                                                | Allowed for any owned non-archived group. Quantity > 0. Feed name and unit required.                                                                                                                                                                                |
| EggProduction  | id, poultry_group_id, owner_id, produced_at, quantity, unit, price_per_unit, note?, created_at, updated_at                                                                                                      | Allowed only when group type is `layer`, `duck`, or `local`. Rejected for `broiler`. Quantity > 0. Unit required. Price per unit ≥ 0.                                                                                                                               |

## Value Objects

| Value Object      | Properties   | Constraints                                                               |
| ----------------- | ------------ | ------------------------------------------------------------------------- |
| PoultryType       | value        | One of `broiler`, `duck`, `layer`, `local`                                |
| AcquisitionSource | value        | `purchased` or `born_on_farm`                                             |
| BirdCount         | value        | Integer ≥ 0                                                               |
| MoneyAmount       | amount       | Non-negative decimal for purchase_price / price_per_unit                  |
| Quantity          | amount, unit | amount > 0; unit non-empty string                                         |
| GroupName         | value        | Required non-empty display name; **not unique** — identity is always `id` |
| ArchiveFlag       | is_archived  | Soft retire; archived groups hidden from default active lists             |

## Aggregates

| Aggregate Root | Members                                                                                                  | Invariants                                                                                                                                                                                                                                                                                                                 |
| -------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PoultryGroup   | Group profile + bird_count; child PoultryFeeding and EggProduction collections (egg eligibility by type) | Owner immutable for v1. Purchase fields only when purchased. Egg entries rejected if type is `broiler`. Archiving does not delete history; **block new feeding/egg/writes on archived groups** (align ADR-004); history remains GET-able by id. Bird count updates are explicit field updates (not separate stock ledger). |

## Domain Events

| Event                  | Trigger                           | Payload                                               |
| ---------------------- | --------------------------------- | ----------------------------------------------------- |
| PoultryGroupRegistered | Group created                     | group_id, owner_id, poultry_type, name, bird_count    |
| PoultryGroupUpdated    | Group fields / bird count changed | group_id, changed_fields                              |
| PoultryGroupArchived   | Group archived                    | group_id, archived_at                                 |
| PoultryFeedingRecorded | Feeding entry added               | group_id, entry_id, fed_at, feed_name, quantity, unit |
| EggProductionRecorded  | Egg entry added                   | group_id, entry_id, produced_at, quantity, unit       |

## Domain Services

| Service               | Operations                                                   | Dependencies                                                               |
| --------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------- |
| PoultryGroupService   | create, get, list_active, update (incl. bird_count), archive | PoultryGroupRepository, owner auth                                         |
| PoultryFeedingService | add, list_by_group                                           | PoultryGroupRepository, PoultryFeedingRepository                           |
| EggProductionService  | add, list_by_group                                           | PoultryGroupRepository, EggProductionRepository; enforces type eligibility |

## Repository Interfaces

| Repository               | Entity         | Methods                                                                        |
| ------------------------ | -------------- | ------------------------------------------------------------------------------ |
| PoultryGroupRepository   | PoultryGroup   | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive |
| PoultryFeedingRepository | PoultryFeeding | save; list_by_group(owner_id, group_id, paging?)                               |
| EggProductionRepository  | EggProduction  | save; list_by_group(owner_id, group_id, paging?)                               |

All queries filter by `owner_id`. Child tables carry denormalized `owner_id` (ADR-005).

## Ubiquitous Language

| Term           | Definition                                                |
| -------------- | --------------------------------------------------------- |
| Poultry group  | Named batch/flock of birds of one poultry type            |
| Poultry type   | broiler, duck, layer, or local                            |
| Bird count     | Current number of birds in the group                      |
| Archive        | Soft-retire a group from active lists without hard delete |
| Feeding        | Timestamped feed intake for a poultry group               |
| Egg production | Timestamped egg yield for egg-eligible types              |
| Acquired by    | How the group entered the farm: purchased or born on farm |

## Story Coverage

| Story                            | Domain coverage                                                                           |
| -------------------------------- | ----------------------------------------------------------------------------------------- |
| 001-api-poultry-groups           | PoultryGroup aggregate, bird_count, purchase rules, archive, owner scoping                |
| 002-api-poultry-feeding-and-eggs | Feeding for any group; EggProduction eligibility (layer/duck/local); broiler without eggs |

## Open Questions Deferred to Technical Design

- Group name uniqueness → resolved in design: **not unique**; identify by `id`
- Default list paging limits → resolved: limit 20 default, max 100
- Whether archived group GET remains allowed → resolved: yes; writes blocked
- Numeric precision for money/quantity → resolved: Numeric 12,2 / 12,3 (match cows)

## Relevant Prior Decisions

- **ADR-004**: Soft-archive + write block; no unarchive in v1 — apply to poultry groups
- **ADR-005**: Denormalize `owner_id` on feeding/egg child tables
- **ADR-002**: Sync SQLAlchemy persistence (implementation stage)
