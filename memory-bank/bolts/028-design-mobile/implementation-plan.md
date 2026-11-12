---
unit: 003-design-mobile
bolt: 028-design-mobile
stage: plan
status: complete
updated: "2026-11-12T09:30:00Z"
---

# Implementation Plan — 028-design-mobile

## Scope

Mobile cow detail parity with web bolt 024/025: paginated milk/feeding histories, `total` + feeding `unit_cost`, PATCH/DELETE row actions, detail chrome layout, l10n/a11y.

## Steps

1. **Domain/data** — Extend `MilkProduction`/`CowFeeding` with `total`; feeding `unitCost`; `CowsApi` PATCH/DELETE; repository + use cases (`Update*`/`Delete*`); DI registration; `addFeeding` requires `unit_cost`.
2. **UI** — `OffsetPaginationControls` (limit 10); `cow_detail_page` DataTables, edit/delete dialogs, form edit mode; responsive image left / info right via `LayoutBuilder`; `CowImagePanel` semantics + rectangular chrome dimensions.
3. **l10n** — EN/BN strings for Total, unit cost, pagination, delete confirms, cow photo alt, form hints.
4. **Tests** — Mapper totals/unit_cost; `rowTotal` helper; l10n assertions.
5. **Verify** — `flutter gen-l10n`, `flutter test`.

## Non-goals

- Soft delete; suggested-units datalist; other entity pagination (out of bolt scope).
