---
stage: implement
bolt: 008-poultry
created: 2026-11-09T11:42:43Z
---

# Implementation Walkthrough: Poultry (Web)

## Summary

Added poultry management to the existing React SPA: list/create/edit/archive poultry groups and record/review feeding and eggs under protected routes, using the shared API client and error banner patterns from the cows web bolt.

## Structure Overview

New feature folder `web/src/features/poultry` with types, API wrappers, shared group form, and list/create/detail pages. Detail page hosts egg and feeding sections. App shell nav and home CTAs point to poultry.

## Completed Work

- [x] `web/src/features/poultry/types.ts` — Group, feeding, egg DTOs and inputs
- [x] `web/src/features/poultry/api/poultryApi.ts` — Authenticated poultry/feeding/egg API calls
- [x] `web/src/features/poultry/components/PoultryGroupForm.tsx` — Create/edit form with purchase-field toggle
- [x] `web/src/features/poultry/pages/PoultryListPage.tsx` — Active list + include-archived toggle
- [x] `web/src/features/poultry/pages/PoultryCreatePage.tsx` — Create flow
- [x] `web/src/features/poultry/pages/PoultryDetailPage.tsx` — Detail, edit, archive, eggs, feeding
- [x] `web/src/App.tsx` — Routes `/poultry`, `/poultry/new`, `/poultry/:groupId`
- [x] `web/src/shared/ui/AppShell.tsx` — Poultry nav link
- [x] `web/src/features/auth/pages/HomePage.tsx` — CTA to poultry
- [x] Vitest coverage for form purchase toggle, list success/error, create API error banner

## Key Decisions

- **Single detail page** for profile + eggs + feeding to keep navigation shallow for v1
- **Hide egg CTA** for broiler; hide write actions when archived (ADR-004)
- **No client uniqueness** on group names (API identity is `group_id`)
- **Reuse ErrorBanner + ApiError.message** for all mutation/query failures

## Deviations from Plan

None material. Broader Stage 3 test walkthrough still pending.

## Dependencies Added

None (reused React Router + TanStack Query already in the SPA).

## Developer Notes

- Requires backend with poultry migration applied and owner signed in
- `npm test -- --run src/features/poultry` and `npm run build` verified after implementation
