---
stage: plan
bolt: 005-cows
created: 2026-11-09T11:06:49Z
---

# Implementation Plan: Cows (Web)

## Objective

Add signed-in cow workflows to the existing React (Vite) SPA so the owner can list/create/edit/archive cows and record/review milk and feeding against the completed `/api/v1` cows contract from bolt `004-cows`.

## Story in Scope

- **003-web-cows**: Manage cows, milk, and feeding in the browser using shared API error handling

## Deliverables

1. Feature module under `web/src/features/cows` (API client, types, pages/components)
2. Typed cows / milk / feeding DTOs and TanStack Query hooks against:
   - `GET|POST /api/v1/cows`
   - `GET|PATCH /api/v1/cows/{id}`
   - `POST /api/v1/cows/{id}/archive`
   - `GET|POST /api/v1/cows/{id}/milk-productions`
   - `GET|POST /api/v1/cows/{id}/feedings`
3. Screens/routes (protected, inside `AppShell`):
   - Active cows list (default); optional toggle/link for archived
   - Create cow form
   - Cow detail (view + edit active fields; archive action; read-only when archived)
   - Milk history + add milk (hidden/disabled for meat-only and archived)
   - Feeding history + add feeding (disabled when archived)
4. Reuse existing `apiClient`, `ErrorBanner` / `ApiError` handling (`message` + `code`)
5. Nav link to Cows from `AppShell`
6. Critical-path Vitest coverage (API error mapping / form validation UX or list empty/error states)

## Dependencies

1. **`004-cows` (API)** — complete; OpenAPI at backend `/docs`
2. **`002-platform-and-auth` (web)** — existing SPA, session, protected routes, TanStack Query
3. **Prior ADRs (consume, do not re-decide)**:
   - ADR-004 soft-archive + write block → UI: confirm archive; no edit/add on archived
   - ADR-006 active-only tag uniqueness → surface `TAG_ALREADY_EXISTS`; allow reuse after archive via API
4. **Suggested units**: optional `GET /api/v1/config/suggested-units` for milk/feed unit hints

## Technical Approach

1. **Extend types** in feature-local types (or shared types file) for `Cow`, `MilkProduction`, `CowFeeding`, paged `{ items, meta }`
2. **`cowsApi.ts`**: thin wrappers over existing authenticated `apiClient` (snake_case JSON)
3. **Routes**: `/cows`, `/cows/new`, `/cows/:cowId` (detail with tabs or stacked sections for milk/feeding)
4. **Forms**: purpose `milk|meat|both`; gender `female|male|unknown`; acquired_by with conditional purchase fields; show API `message` on failure
5. **Queries**: invalidate cows list/detail after mutations; milk/feeding lists keyed by `cowId`
6. **UX**: light, non-dashboard; one primary CTA per view; archive behind confirm; meat cows omit milk CTA
7. **Styling**: reuse existing CSS variables / btn / form patterns from auth screens

## Out of Scope

- Flutter / mobile cows (bolt `006-cows`)
- Unarchive, hard delete, multi-farm
- Inventory linkage for feed
- Bangla web localization
- Hosting / Docker

## Acceptance Criteria

- [ ] Signed-in owner can list active cows and open detail
- [ ] Owner can create and edit a cow; purchase fields shown only when acquired by purchase
- [ ] Owner can archive a cow; it leaves the default active list; detail remains readable
- [ ] Owner can add/list milk for milk/both cows; meat-only cannot add milk (UI + API error path)
- [ ] Owner can add/list feeding for a cow
- [ ] Archived cow: no profile edit / no new milk or feeding; API `COW_ARCHIVED` / `message` shown if attempted
- [ ] API validation/conflict errors (`TAG_ALREADY_EXISTS`, `PURCHASE_FIELDS_INVALID`, etc.) use shared error handling
- [ ] Critical-path tests pass for cows UI error / key workflow behavior

## Relevant Prior Decisions

- ADR-004, ADR-005, ADR-006 constrain API behavior the UI must respect
- Web auth session / refresh handling unchanged from platform web bolt
