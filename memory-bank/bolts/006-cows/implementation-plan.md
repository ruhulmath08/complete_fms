---
stage: plan
bolt: 006-cows
created: 2026-11-09T11:12:56Z
---

# Implementation Plan: Cows (Mobile)

## Objective

Extend the existing Flutter app so a signed-in owner can list/create/edit/archive cows and record/review milk and feeding against `/api/v1` cows endpoints, with Bangla and English strings, matching the web cows workflows from bolt `005-cows`.

## Story in Scope

- **004-mobile-cows**: Mobile cow / milk / feeding workflows with EN+BN localization

## Deliverables

1. Clean Architecture cows slice under `mobile/lib/`:
   - `domain/` — cow / milk / feeding entities, repository port, use cases
   - `data/` — API datasource, mappers, repository impl
   - `presentation/cows/` — BLoCs/Cubits + screens (list, create/edit, detail with milk & feeding)
2. Wire into existing GoRouter (protected shell), GetIt DI, Dio client with Bearer + refresh
3. Screens parity with web:
   - Active cows list; include-archived toggle
   - Create / edit cow (purchase fields when purchased)
   - Detail: view, archive confirm, milk list/add (milk|both only), feeding list/add
   - Archived: read-only (no edit / no new milk or feeding)
4. Surface API `message` via existing failure/error patterns; honor codes like `TAG_ALREADY_EXISTS`, `COW_ARCHIVED`, `MILK_NOT_ALLOWED_FOR_PURPOSE`
5. ARB strings for cow screens in `en` and `bn`
6. Critical-path tests (domain rules and/or cows Cubit/use-case)

## Dependencies

1. **`004-cows` (API)** — complete
2. **`005-cows` (Web)** — complete (UX/contract reference)
3. **`003-platform-and-auth` (Mobile)** — existing app shell, session, l10n, DI, API client
4. **Endpoints**: same cows/milk/feeding contract as web
5. **ADRs to honor (UI only)**: ADR-004 archive write-block; ADR-006 active tag uniqueness / reuse after archive

## Technical Approach

1. **Domain entities** mirror API snake_case fields as Dart types (purpose/gender/acquired_by enums)
2. **`CowsRepository`** port + Dio-backed impl using existing authenticated client
3. **Presentation**: Cubit/BLoC per screen or feature (list, form, detail sections) — follow patterns from auth presentation
4. **Navigation**: `/cows`, `/cows/new`, `/cows/:id` under authenticated shell; home/shell entry to Cows
5. **Localization**: add cow-related keys to `app_en.arb` / `app_bn.arb`; regenerate localizations
6. **Errors**: map `AppFailure` / API error body to SnackBar or inline banner using `message`
7. **Suggested units**: optional fetch of `/api/v1/config/suggested-units` for unit hints

## Out of Scope

- Web changes
- Unarchive / hard delete / multi-farm
- Inventory linkage
- Store release / CI signing

## Acceptance Criteria

- [ ] Signed-in owner can list active cows and open detail on mobile
- [ ] Owner can create and edit a cow; purchase fields only when purchased
- [ ] Owner can archive; archived leaves default list; detail readable and write-blocked
- [ ] Milk add/list for milk/both; meat-only cannot add milk
- [ ] Feeding add/list for any active cow
- [ ] Cow UI strings available in English and Bangla
- [ ] API errors show user-facing `message` consistently with auth/web
- [ ] Critical-path tests pass

## Relevant Prior Decisions

- ADR-004, ADR-006 constrain lifecycle/tag behavior the UI must respect
- Mobile auth session/refresh unchanged from platform mobile bolt
