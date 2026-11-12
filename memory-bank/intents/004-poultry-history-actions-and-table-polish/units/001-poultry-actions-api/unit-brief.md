---
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
phase: construction
status: complete
created: "2026-11-12T09:47:02Z"
updated: "2026-11-12T09:55:00Z"
unit_type: backend
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: 001-poultry-actions-api

## Purpose

Add owner-scoped PATCH/DELETE for poultry egg productions and poultry feedings so web/mobile Action columns can maintain history after insert (hard-delete; archive/authz parity with cows).

## Scope

### In Scope

- Egg production update/delete endpoints and services
- Poultry feeding update/delete endpoints and services
- Domain guards for archived groups and ownership
- Automated tests

### Out of Scope

- Soft-delete
- Web/mobile UI
- Changing create/list contracts except as needed for consistency

## Assigned Requirements

| FR  | Requirement                         | Priority |
| --- | ----------------------------------- | -------- |
| FR-1 | Egg production update/delete (API) | Must     |
| FR-2 | Poultry feeding update/delete (API)| Must     |

## Domain Concepts

| Entity / Op        | Description                          |
| ------------------ | ------------------------------------ |
| EggProduction      | Poultry egg history row              |
| PoultryFeeding     | Poultry feeding history row          |
| Update egg/feeding | Patch fields on existing row         |
| Delete egg/feeding | Hard-delete row                      |

## Story Summary

- [x] **001-api-egg-update-delete**: Egg PATCH/DELETE - Must
- [x] **002-api-poultry-feeding-update-delete**: Feeding PATCH/DELETE - Must

## Dependencies

- Extends existing poultry module from intent `001`
- Enables web/mobile Action units

## Success Criteria

- [x] Egg and feeding support PATCH + DELETE with archive/authz tests
- [x] Clients can implement Action without client-only hacks
