---
stage: implement
bolt: 030-poultry-actions-web
created: "2026-11-12T10:05:00Z"
---

# Implementation Walkthrough: 030-poultry-actions-web

## Summary

Wired poultry egg and feeding history Action (Edit/Delete) on the React detail page against bolt `029` APIs, renamed web history index headers to **No.**, and aligned Edit primary / Delete danger icon styles with cow tables.

## Structure Overview

Poultry API client gained nested PATCH/DELETE helpers; detail page egg/feeding sections now mirror the cow milk/feeding edit-into-form and confirm-delete pattern. Shared CSS adds resting primary and danger icon colors used by poultry and cow Action buttons.

## Completed Work

- [x] `web/src/features/poultry/types.ts` - Egg/feeding update input types
- [x] `web/src/features/poultry/api/poultryApi.ts` - PATCH/DELETE egg and feeding clients
- [x] `web/src/features/poultry/pages/PoultryDetailPage.tsx` - Action columns, edit/delete, No. headers
- [x] `web/src/features/poultry/pages/PoultryDetailPage.test.tsx` - Critical-path Action / archive Vitest
- [x] `web/src/features/cows/pages/CowDetailPage.tsx` - No. headers + primary Edit icons
- [x] `web/src/features/crops/pages/CropCycleDetailPage.tsx` - Expense/harvest No. headers
- [x] `web/src/index.css` - `btn-icon-primary` and resting `btn-icon-danger` styles

## Key Decisions

- **Mirror cow UX**: Shared form for add/update with Cancel edit; `window.confirm` before delete
- **Hide Action when archived**: Same `canAdd` gate as cow writable sections
- **Primary Edit at rest**: New `.btn-icon-primary` so Edit is distinct without relying on hover alone

## Deviations from Plan

None

## Dependencies Added

None

## Developer Notes

- Vitest covers Action presence, delete confirm path, and archived Action hide; Stage 3 will formalize the test report
- Mobile Action/No. remains bolt `031`
