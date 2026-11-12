---
unit: 001-poultry-actions-api
bolt: 029-poultry-actions-api
stage: domain-model
status: complete
updated: "2026-11-12T09:51:00Z"
---

# Domain Model - 029-poultry-actions-api

## Bounded Context

**Poultry** — extend egg production and feeding history with **update** and **hard-delete**, matching cow milk/feeding mutation rules from bolt `024`.

## Aggregates / Entities

| Entity | Root | Notes |
|--------|------|-------|
| PoultryGroup | Yes | Ownership + `is_archived`; eggs eligibility by type |
| EggProduction | Child of group | `produced_at`, qty, unit, `price_per_unit`, note |
| PoultryFeeding | Child of group | `fed_at`, feed_name, qty, unit, note |

## Domain Rules

1. Mutations require owner-owned group; missing/cross-owner → `POULTRY_GROUP_NOT_FOUND` / `EGG_NOT_FOUND` / `POULTRY_FEEDING_NOT_FOUND`
2. Archived group → `POULTRY_GROUP_ARCHIVED` (409) blocks update/delete
3. Egg update still requires eggs-eligible poultry type (`assert_eggs_allowed`)
4. Quantity / unit / price / feed_name validation reuse existing poultry domain validators
5. Delete is **hard-delete** (row removed)

## Ubiquitous Language

| Term | Meaning |
|------|---------|
| Egg production | Layer/duck/local egg history row |
| Poultry feeding | Feed history row for any group type |
| Hard-delete | Permanent row removal (no soft flag) |

## Out of Scope

- Soft-delete, unit_cost on poultry feeding, web/mobile UI
