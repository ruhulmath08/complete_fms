---
unit: 003-design-mobile
bolt: 028-design-mobile
stage: implement
status: complete
updated: "2026-11-12T09:30:00Z"
---

# Implementation Walkthrough — 028-design-mobile

## Summary

Cow detail now matches web for milk/feeding histories: page size 10, Total column, feeding unit cost on list/forms, hard delete with confirm, edit via PATCH. Archived cows remain read-only (no row actions or add forms).

## Data layer

- Entities/mappers: `total`, `unit_cost`
- API: `updateMilk`, `deleteMilk`, `updateFeeding`, `deleteFeeding`
- Use cases registered in `injection.dart`

## Presentation

- `offset_pagination_controls.dart` — Previous/Next + summary
- `cow_detail_page.dart` — horizontal `DataTable`s, offset state per section, edit/delete wired
- `cow_image_panel.dart` — optional width/height, semantics label, no-photo placeholder
- Detail chrome: Row (&lt;520px stacks) with 148×186 image

## l10n

- `app_en.arb` / `app_bn.arb` — pagination, totals, unit cost, delete confirms, cow photo alt

## Verification

```bash
cd mobile && flutter gen-l10n && flutter test
# 39 passed
```
