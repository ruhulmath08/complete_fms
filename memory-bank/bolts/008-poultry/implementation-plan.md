---
stage: plan
bolt: 008-poultry
created: 2026-11-09T11:34:48Z
---

# Implementation Plan: Poultry (Web)

## Objective

Add signed-in poultry workflows to the existing React (Vite) SPA so the owner can list/create/edit/archive poultry groups and record/review feeding and egg production against the completed `/api/v1` poultry contract from bolt `007-poultry`.

## Story in Scope

- **003-web-poultry**: Manage poultry groups, bird counts, feeding, and applicable eggs in the browser using shared API error handling

## Deliverables

1. Feature module under `web/src/features/poultry` (API client, types, pages/components)
2. Typed poultry / feeding / egg DTOs and TanStack Query usage against:
   - `GET|POST /api/v1/poultry-groups`
   - `GET|PATCH /api/v1/poultry-groups/{id}`
   - `POST /api/v1/poultry-groups/{id}/archive`
   - `GET|POST /api/v1/poultry-groups/{id}/feedings`
   - `GET|POST /api/v1/poultry-groups/{id}/egg-productions`
3. Screens/routes (protected, inside `AppShell`):
   - Active groups list (default); optional include-archived toggle
   - Create group form
   - Group detail (view + edit active fields incl. bird_count; archive action; read-only when archived)
   - Feeding history + add feeding (disabled when archived)
   - Egg history + add eggs (hidden/disabled for broiler and archived)
4. Reuse existing `apiClient`, `ErrorBanner` / `ApiError` handling (`message` + `code`)
5. Nav link to Poultry from `AppShell`; home CTA alongside cows
6. Critical-path Vitest coverage (form validation UX and/or list empty/error states), mirroring cows web tests

## Dependencies

1. **`007-poultry` (API)** — complete; OpenAPI at backend `/docs`
2. **`002-platform-and-auth` (web)** + **`005-cows` (web)** — SPA session, protected routes, cows feature patterns to mirror
3. **Prior ADRs (consume, do not re-decide)**:
   - ADR-004 soft-archive + write block → UI: confirm archive; no edit/add on archived
   - ADR-005 denormalized child `owner_id` → no client-side owner fields
4. **Design constraints from 007**: group names are **not** unique; identity is `group_id`; eggs only for duck/layer/local

## Technical Approach

1. **Extend types** in `web/src/features/poultry/types.ts` for `PoultryGroup`, `PoultryFeeding`, `EggProduction`, paged `{ items, meta }`
2. **`poultryApi.ts`**: thin wrappers over authenticated `apiClient` (snake_case JSON)
3. **Routes**: `/poultry`, `/poultry/new`, `/poultry/:groupId` (detail with stacked sections for feeding/eggs)
4. **Forms**: `poultry_type` broiler|duck|layer|local; `acquired_by` with conditional purchase fields; bird_count ≥ 0; show API `message` on failure
5. **Queries**: invalidate group list/detail after mutations; feeding/egg lists keyed by `groupId`
6. **UX**: mirror cows — light, non-dashboard; one primary CTA per view; archive behind confirm; broiler omits egg CTA; duplicate names allowed (no client uniqueness check)
7. **Styling**: reuse existing CSS variables / btn / form / list patterns from cows screens

## Out of Scope

- Flutter / mobile poultry (bolt `009-poultry`)
- Unarchive, hard delete, multi-farm
- Inventory linkage for feed
- Bangla web localization
- Hosting / Docker

## Acceptance Criteria

- [ ] Signed-in owner can list active poultry groups and open detail
- [ ] Owner can create and edit a group (incl. bird_count); purchase fields only when purchased
- [ ] Owner can archive a group; it leaves the default active list; detail remains readable
- [ ] Multiple groups may share the same display name
- [ ] Owner can add/list feeding for any group type
- [ ] Owner can add/list eggs for duck/layer/local; broiler has no egg add CTA (API error path still handled)
- [ ] Archived group: no profile edit / no new feeding or eggs; API `POULTRY_GROUP_ARCHIVED` / `message` shown if attempted
- [ ] API validation errors (`PURCHASE_FIELDS_INVALID`, `EGGS_NOT_ALLOWED_FOR_TYPE`, etc.) use shared error handling
- [ ] Critical-path Vitest tests pass for poultry UI key workflows

## Relevant Prior Decisions

- ADR-004, ADR-005 constrain API behavior the UI must respect
- Web auth session / refresh handling unchanged from platform web bolt
- Cows web feature (`005-cows`) is the structural template
