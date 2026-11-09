---
stage: plan
bolt: 009-poultry
created: 2026-11-09T11:48:47Z
---

# Implementation Plan: Poultry (Mobile)

## Objective

Extend the existing Flutter app so a signed-in owner can list/create/edit/archive poultry groups and record/review feeding and egg production against `/api/v1` poultry endpoints, with Bangla and English strings, matching the web poultry workflows from bolt `008-poultry`.

## Story in Scope

- **004-mobile-poultry**: Mobile poultry group / feeding / eggs workflows with EN+BN localization

## Deliverables

1. Clean Architecture poultry slice under `mobile/lib/`:
   - `domain/` — poultry group / feeding / egg entities, repository port, use cases
   - `data/` — API datasource, mappers, repository impl
   - `presentation/poultry/` — screens (list, create/edit, detail with feeding & eggs)
2. Wire into existing GoRouter (protected shell), GetIt DI, Dio client with Bearer + refresh
3. Screens parity with web:
   - Active groups list; include-archived toggle
   - Create / edit group (bird_count; purchase fields when purchased; names not unique)
   - Detail: view, archive confirm, feeding list/add, egg list/add (duck|layer|local only)
   - Archived: read-only (no edit / no new feeding or eggs)
4. Surface API `message` via existing failure/error patterns; honor codes like `POULTRY_GROUP_ARCHIVED`, `EGGS_NOT_ALLOWED_FOR_TYPE`, `PURCHASE_FIELDS_INVALID`
5. ARB strings for poultry screens in `en` and `bn`
6. Critical-path tests (domain rules and/or poultry use-case)

## Dependencies

1. **`007-poultry` (API)** — complete
2. **`008-poultry` (Web)** — complete (UX/contract reference)
3. **`003-platform-and-auth` (Mobile)** + **`006-cows` (Mobile)** — app shell, session, l10n, DI, API client; cows slice as structural template
4. **Endpoints**: same poultry-groups / feedings / egg-productions contract as web
5. **ADRs to honor (UI only)**: ADR-004 archive write-block; ADR-005 child owner_id is server-side only

## Technical Approach

1. **Domain entities** mirror API snake_case fields as Dart types (`poultry_type` / `acquired_by` enums)
2. **`PoultryRepository`** port + Dio-backed impl using existing authenticated client
3. **Presentation**: follow cows presentation patterns (StatefulWidget / Cubit as used there)
4. **Navigation**: `/poultry`, `/poultry/new`, `/poultry/:id` under authenticated shell; home/shell entry to Poultry
5. **Localization**: add poultry-related keys to `app_en.arb` / `app_bn.arb`; regenerate localizations
6. **Errors**: map `AppFailure` / API error body to SnackBar or inline banner using `message`
7. **Suggested units**: optional fetch of `/api/v1/config/suggested-units` for unit hints
8. **Eggs**: hide add UI for broiler; still handle `EGGS_NOT_ALLOWED_FOR_TYPE` if API rejects

## Out of Scope

- Web changes
- Unarchive / hard delete / multi-farm
- Inventory linkage
- Store release / CI signing

## Acceptance Criteria

- [ ] Signed-in owner can list active poultry groups and open detail on mobile
- [ ] Owner can create and edit a group (incl. bird_count); purchase fields only when purchased
- [ ] Duplicate display names allowed; identity is group id
- [ ] Owner can archive; archived leaves default list; detail readable and write-blocked
- [ ] Feeding add/list for any active group
- [ ] Eggs add/list for duck/layer/local; broiler has no egg add CTA
- [ ] Poultry UI strings available in English and Bangla
- [ ] API errors show user-facing `message` consistently with auth/cows/web
- [ ] Critical-path tests pass

## Relevant Prior Decisions

- ADR-004, ADR-005 constrain lifecycle/ownership behavior the UI must respect
- Mobile auth session/refresh unchanged from platform mobile bolt
- Cows mobile feature (`006-cows`) is the structural template
