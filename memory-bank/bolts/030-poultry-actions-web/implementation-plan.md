---
stage: plan
bolt: 030-poultry-actions-web
created: "2026-11-12T10:00:00Z"
---

# Implementation Plan: 030-poultry-actions-web

## Objective

Wire poultry Egg production and Feeding **Action** (Edit/Delete) on React poultry detail using bolt `029` APIs; rename history index headers `#`/`No` → **No.** across web history tables; make Edit primary and Delete danger styling consistent (including cow milk/feeding).

## Stories

- **001-web-poultry-egg-feeding-actions**: Poultry Action columns
- **002-web-history-no-and-action-colors**: No. + Action colors

## Deliverables

- `poultryApi` PATCH/DELETE for eggs and feedings (+ update input types)
- `PoultryDetailPage` Egg/Feeding sections: Action column, edit-into-form, confirm delete, refresh lists; hide/disable when archived / eggs ineligible
- Header **No.** on poultry, cow, and crop history tables (and any other `#` history tables found)
- CSS: primary Edit icon style; keep `btn-icon-danger` for Delete; apply on poultry + cow Action icons
- Preserve add egg/feeding flows (FR-8)
- Vitest coverage for poultry Action / API client critical path where practical

## Dependencies

- **029-poultry-actions-api** (complete): egg/feeding PATCH/DELETE
- Pattern reference: `CowDetailPage` milk/feeding Action UX

## Technical Approach

1. Add `EggUpdateInput` / `FeedingUpdateInput` and `updateEggProduction` / `deleteEggProduction` / `updatePoultryFeeding` / `deletePoultryFeeding` mirroring cows API client
2. Mirror cow `MilkSection`/`FeedingSection` patterns in poultry sections: `editingId`, shared form for add/update, `window.confirm` on delete, Action column when `canAdd`
3. Replace `#` / bare `No` table headers with **No.**
4. Add `.btn-icon-primary` (or equivalent) so Edit is clearly primary at rest; Delete stays `.btn-icon-danger`
5. Update Vitest (poultry detail or API mocks) for Action presence / mutation wiring

## Acceptance Criteria

- [ ] Egg and Feeding tables show **Action** with Edit (primary) and Delete (danger) when writable
- [ ] Edit saves via PATCH and refreshes; Delete confirms then DELETE + refresh; Cancel leaves row
- [ ] Archived group (and eggs-ineligible) hide/disable actions appropriately; add still works when allowed
- [ ] All web history index headers use **No.**
- [ ] Cow Action colors aligned with primary Edit / danger Delete
- [ ] Critical-path Vitest passes

## Out of Scope

- Mobile UI (bolt `031`)
- Soft-delete; poultry feeding `unit_cost`
