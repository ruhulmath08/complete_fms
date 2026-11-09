---
stage: implement
bolt: 011-crops
created: 2026-11-09T12:20:00Z
---

# Implementation Walkthrough: Crops (Web)

## Summary

Added crop management to the React SPA: catalog (crop names), planting cycles, expenses, harvests, and cycle summary under protected routes, using the shared API client and error banner patterns from poultry/cows web bolts.

## Structure Overview

New feature folder `web/src/features/crops` with types, API wrappers, name/cycle forms, and list/create/detail pages. Cycle detail hosts summary, expenses, and harvests. App shell nav and home CTA point to crops.

## Completed Work

- [x] `web/src/features/crops/types.ts` — Name, cycle, expense, harvest, summary DTOs
- [x] `web/src/features/crops/api/cropsApi.ts` — Authenticated crops API wrappers
- [x] `web/src/features/crops/components/CropNameForm.tsx` — Create/edit crop name
- [x] `web/src/features/crops/components/CropCycleForm.tsx` — Create/edit cycle with crop picker
- [x] `web/src/features/crops/pages/CropCyclesListPage.tsx` — Primary cycles list + include-archived
- [x] `web/src/features/crops/pages/CropNamesListPage.tsx` — Catalog list
- [x] `web/src/features/crops/pages/CropNameCreatePage.tsx` / `CropNameDetailPage.tsx` — Name CRUD + archive
- [x] `web/src/features/crops/pages/CropCycleCreatePage.tsx` / `CropCycleDetailPage.tsx` — Cycle CRUD, summary, expenses, harvests
- [x] `web/src/App.tsx` — Routes under `/crops`
- [x] `AppShell` + `HomePage` — Crops nav/CTA
- [x] Vitest: cycles list success/error, duplicate name banner, cycle form submit

## Key Decisions

- **Cycles as primary hub** at `/crops`; names under `/crops/names`
- **Hide write actions** when archived (ADR-004); surface `CROP_NAME_ALREADY_EXISTS` via ErrorBanner (ADR-007)
- **Active-only picker** for new cycles; edit may keep current name in options
- **Reuse ErrorBanner + ApiError.message** for query/mutation failures

## Deviations from Plan

None material. Broader Stage 3 test walkthrough still pending.

## Dependencies Added

None (reused React Router + TanStack Query).

## Developer Notes

- Requires backend with crops migration applied and owner signed in
- `npm test -- --run src/features/crops` and `npm run build` verified after implementation
