---
stage: plan
bolt: 011-crops
created: 2026-11-09T12:14:33Z
---

# Implementation Plan: Crops (Web)

## Objective

Add signed-in crop workflows to the existing React (Vite) SPA so the owner can manage the crop-name catalog, crop cycles, expenses, harvests, and cycle summary against the completed `/api/v1` crops contract from bolt `010-crops`.

## Story in Scope

- **003-web-crops**: Catalog, cycles, expenses, harvests, and summary in the browser using shared API error handling

## Deliverables

1. Feature module under `web/src/features/crops` (API client, types, pages/components)
2. Typed DTOs and TanStack Query usage against:
   - `GET|POST /api/v1/crop-names`, `GET|PATCH /api/v1/crop-names/{id}`, `POST .../archive`
   - `GET|POST /api/v1/crop-cycles`, `GET|PATCH /api/v1/crop-cycles/{id}`, `POST .../archive`
   - `GET /api/v1/crop-cycles/{id}/summary`
   - `GET|POST /api/v1/crop-cycles/{id}/expenses`
   - `GET|POST /api/v1/crop-cycles/{id}/harvests`
3. Screens/routes (protected, inside `AppShell`):
   - Crop names list (+ create/edit/archive; include-archived toggle)
   - Cycles list (+ create; include-archived toggle)
   - Cycle detail: view/edit/archive; summary panel; expenses add/list; harvests add/list
   - Create cycle form with crop-name picker (active names only)
4. Reuse `apiClient`, `ErrorBanner` / `ApiError` (`message` + `code`)
5. Nav link to Crops from `AppShell`; home CTA alongside cows/poultry
6. Critical-path Vitest (list error banner and/or form purchase-style validation patterns)

## Dependencies

1. **`010-crops` (API)** — complete; OpenAPI at backend `/docs`
2. **`008-poultry` / `005-cows` (web)** — SPA patterns to mirror
3. **ADRs**: ADR-004 archive write-block; ADR-007 active crop-name uniqueness → surface `CROP_NAME_ALREADY_EXISTS`; reuse after archive via API

## Technical Approach

1. **Types** in `web/src/features/crops/types.ts`
2. **`cropsApi.ts`**: thin authenticated wrappers
3. **Routes**: `/crops` (hub or names list), `/crops/names`, `/crops/names/new`, `/crops/cycles`, `/crops/cycles/new`, `/crops/cycles/:cycleId` — prefer shallow tree: `/crops/names`, `/crops/cycles`, `/crops/cycles/:cycleId` with names managed from a Names tab/section under `/crops` or dedicated `/crops/names`
4. **Suggested IA** (mirror poultry depth):
   - `/crops` → cycles list (primary)
   - `/crops/names` → catalog list
   - `/crops/names/new`, `/crops/cycles/new`, `/crops/cycles/:cycleId`
5. **UX**: confirm archive; hide writes when archived; show summary on detail; expense category select; optional sale amount on harvest
6. **Styling**: reuse existing CSS / form / list patterns

## Out of Scope

- Flutter (012-crops)
- Unarchive, expense/harvest edit/delete
- Bangla web localization
- Hosting

## Acceptance Criteria

- [x] Owner can list/create/edit/archive crop names; duplicate active name shows API message
- [x] Owner can list/create/edit/archive cycles using catalog picker
- [x] Owner can add/list expenses and harvests on a cycle
- [x] Cycle detail shows summary (expenses, sale income, result)
- [x] Archived cycle/name: no write actions; API errors surfaced via shared banner
- [x] Critical-path Vitest passes

## Relevant Prior Decisions

- ADR-004, ADR-007 constrain UI behavior
- Web auth session unchanged
