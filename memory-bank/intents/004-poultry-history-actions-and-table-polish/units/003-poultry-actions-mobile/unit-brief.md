---
unit: 003-poultry-actions-mobile
intent: 004-poultry-history-actions-and-table-polish
phase: construction
status: complete
created: "2026-11-12T09:47:02Z"
updated: "2026-11-12T10:18:00Z"
unit_type: mobile
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 003-poultry-actions-mobile

## Purpose

Flutter poultry detail: Edit/Delete egg and feeding with confirm; **No.** labeling and primary/danger Action colors; preserve add; BN/EN l10n.

## Scope

### In Scope

- Egg/feeding Edit/Delete + confirm dialogs
- History **No.** / `rowNumber` consistency
- Theme primary vs danger for actions
- Domain/API client wiring for PATCH/DELETE
- BN/EN strings; tests

### Out of Scope

- Web UI
- Soft-delete
- Rebuilding poultry shell/nav

## Assigned Requirements

| FR / NFR | Requirement                  | Priority |
| -------- | ---------------------------- | -------- |
| FR-5     | Mobile egg/feeding Action    | Must     |
| FR-6     | No. column (mobile portion)  | Must     |
| FR-7     | Edit primary / Delete danger | Must     |
| FR-8     | Add path remains (mobile)    | Must     |
| NFR-3    | Localization                 | Must     |

## Story Summary

- [x] **001-mobile-poultry-egg-feeding-actions**: Mobile Edit/Delete - Must
- [x] **002-mobile-history-no-and-action-colors**: No. + colors - Must

## Dependencies

- Requires `001-poultry-actions-api`
- Pattern reference: cow milk/feeding mobile Action from intent `003`

## Success Criteria

- [x] Farm owner can add/edit/delete egg and feeding on mobile
- [x] Confirm on delete; BN/EN strings; No. + color polish
