---
id: 004-mobile-totals-actions-cow-layout
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
updated: "2026-11-12T08:13:02Z"
assigned_bolt: 028-design-mobile
implemented: false
---

# Story: 004-mobile-totals-actions-cow-layout

## User Story

**As a** farm owner
**I want** milk/feeding totals, unit cost, and Edit/Delete on mobile history rows, plus cow image left / info right
**So that** the Flutter app matches the production web cow detail behaviors (not web-only)

## Acceptance Criteria

- [ ] **Given** cow milk history on mobile, **When** rows are shown, **Then** **Total** is visible (from API `total` or quantity × price)
- [ ] **Given** cow feeding history on mobile, **When** rows are shown, **Then** **unit cost** and **Total** are visible
- [ ] **Given** milk or feeding rows, **When** shown and the cow is writable, **Then** **Edit** and **Delete** controls are available (icons or equivalent) with accessible labels
- [ ] **Given** Edit, **When** used, **Then** an edit flow loads the row and saves via PATCH (`updateMilkProduction` / `updateFeeding` API parity)
- [ ] **Given** Delete, **When** confirmed, **Then** the row is removed via DELETE and the list refreshes
- [ ] **Given** feeding create/update forms, **When** shown, **Then** **unit cost** is a required field (aligned with API)
- [ ] **Given** cow detail with image, **When** opened, **Then** rectangular image is left (or top-leading) with info beside/following in a clear two-region layout
- [ ] **Given** archived/read-only, **When** viewing, **Then** edit/delete/create mutations are disabled consistently

## Technical Notes

- Consume bolt `024` contracts: `unit_cost`, response `total`, PATCH/DELETE milk & feeding
- Mirror web cow detail Action + Total behavior; Material 3 icon buttons are fine
- BN/EN l10n for new labels (Total, Unit cost, Edit, Delete, confirm dialogs)

## Dependencies

### Requires

- 001-api-feeding-total-and-list-meta
- 002-api-milk-feeding-update-delete
- 003-mobile-detail-history-pagination

### Enables

- Mobile production parity for FR-12 / FR-13 / FR-14 (Must, not optional)

## Edge Cases

| Scenario                        | Expected Behavior                                                      |
| ------------------------------- | ---------------------------------------------------------------------- |
| Narrow phone                    | Image/info may stack but remain ordered image then info                |
| Delete cancel                   | No API call; list unchanged                                            |
| Missing unit_cost on legacy row | After migration, API always returns unit_cost; show 0.00 if backfilled |

## Out of Scope

- Web Action column (already delivered on cow detail web)
- Soft-delete
