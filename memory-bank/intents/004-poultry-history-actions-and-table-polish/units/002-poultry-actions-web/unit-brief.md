---
unit: 002-poultry-actions-web
intent: 004-poultry-history-actions-and-table-polish
phase: construction
status: complete
created: "2026-11-12T09:47:02Z"
updated: "2026-11-12T10:12:00Z"
unit_type: web
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 002-poultry-actions-web

## Purpose

Wire poultry Egg/Feeding Action columns on React poultry detail; rename history index `#` → **No.** across web history tables; style Edit primary / Delete danger (including cow milk/feeding alignment).

## Scope

### In Scope

- Poultry detail Egg + Feeding Action Edit/Delete + confirm
- `#` → **No.** on all web history tables
- Action icon color polish
- Preserve add flows; Vitest critical path

### Out of Scope

- Mobile UI
- Soft-delete
- New domains

## Assigned Requirements

| FR  | Requirement                    | Priority |
| --- | ------------------------------ | -------- |
| FR-3 | Web egg Action                 | Must     |
| FR-4 | Web feeding Action             | Must     |
| FR-6 | No. column (web portion)       | Must     |
| FR-7 | Edit primary / Delete danger   | Must     |
| FR-8 | Add path remains (web)         | Must     |

## Story Summary

- [x] **001-web-poultry-egg-feeding-actions**: Poultry Action columns - Must
- [x] **002-web-history-no-and-action-colors**: No. + Action colors - Must

## Dependencies

- Requires `001-poultry-actions-api` for Action wiring
- Pattern reference: cow milk/feeding on `CowDetailPage`

## Success Criteria

- [x] Egg and feeding tables have Action Edit/Delete wired to API
- [x] History tables use **No.**; Edit primary / Delete danger
