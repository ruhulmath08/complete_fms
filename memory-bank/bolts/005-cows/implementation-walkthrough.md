---
stage: implement
bolt: 005-cows
created: 2026-11-09T11:08:03Z
---

# Implementation Walkthrough: Cows (Web)

## Summary

Added cow management to the existing React SPA: list/create/edit/archive cows and record/review milk and feeding under protected routes, using the shared API client and error banner patterns from the auth web bolt.

## Structure Overview

New feature folder `web/src/features/cows` with types, API wrappers, shared cow form, and list/create/detail pages. Detail page hosts milk and feeding sections. App shell nav and home CTAs point to cows.

## Completed Work

- [x] `web/src/features/cows/types.ts` — Cow, milk, feeding DTOs and inputs
- [x] `web/src/features/cows/api/cowsApi.ts` — Authenticated cows/milk/feeding API calls
- [x] `web/src/features/cows/components/CowForm.tsx` — Create/edit form with purchase-field toggle
- [x] `web/src/features/cows/pages/CowsListPage.tsx` — Active list + include-archived toggle
- [x] `web/src/features/cows/pages/CowCreatePage.tsx` — Create flow
- [x] `web/src/features/cows/pages/CowDetailPage.tsx` — Detail, edit, archive, milk, feeding
- [x] `web/src/App.tsx` — Routes `/cows`, `/cows/new`, `/cows/:cowId`
- [x] `web/src/shared/ui/AppShell.tsx` — Cows nav link
- [x] `web/src/features/auth/pages/HomePage.tsx` — Primary CTA to cows
- [x] `web/src/index.css` — List/detail layout helpers

## Key Decisions

- **Single detail page** for profile + milk + feeding to keep navigation shallow for v1
- **Hide milk CTA** for meat purpose; hide write actions when archived (ADR-004)
- **Reuse ErrorBanner + ApiError.message** for all mutation/query failures

## Deviations from Plan

None material. Automated UI tests deferred to Stage 3.

## Dependencies Added

None (reused React Router + TanStack Query already in the SPA).

## Developer Notes

- Requires backend with cows migration applied and owner signed in
- `npm run build` verified clean after implementation
