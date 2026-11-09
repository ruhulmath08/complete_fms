---
stage: plan
bolt: 012-crops
created: 2026-11-09T12:28:00Z
---

# Implementation Plan: Crops (Mobile)

## Objective

Extend the existing Flutter app so a signed-in owner can manage the crop-name catalog, crop cycles, expenses, harvests, and cycle summary against `/api/v1` crops endpoints, with Bangla and English strings, matching the web crops workflows from bolt `011-crops`.

## Story in Scope

- **004-mobile-crops**: Mobile crops catalog / cycles / expenses / harvests / summary with EN+BN localization

## Deliverables

1. Clean Architecture crops slice under `mobile/lib/`:
   - `domain/` — crop name / cycle / expense / harvest / summary entities, repository port, use cases
   - `data/` — API datasource, mappers, repository impl
   - `presentation/crops/` — screens (names list/create/detail, cycles list/create/detail with expenses, harvests, summary)
2. Wire into existing GoRouter (protected shell), GetIt DI, Dio client with Bearer + refresh
3. Screens parity with web:
   - Cycles list as primary hub; include-archived toggle; link to crop names
   - Crop names list/create/edit/archive; active uniqueness surfaced via API message
   - Cycle create with active crop-name picker; detail edit/archive; summary panel
   - Expenses add/list (category select); harvests add/list (optional sale amount)
   - Archived name/cycle: read-only (no write CTAs)
4. Surface API `message` via existing failure/error patterns; honor codes like `CROP_NAME_ALREADY_EXISTS`, `CROP_NAME_ARCHIVED`, `CROP_CYCLE_ARCHIVED`
5. ARB strings for crops screens in `en` and `bn`
6. Critical-path tests (domain rules and/or crops use-case)

## Dependencies

1. **`010-crops` (API)** — complete
2. **`011-crops` (Web)** — complete (UX/contract reference)
3. **`003-platform-and-auth` (Mobile)** + **`006-cows` / `009-poultry` (Mobile)** — app shell, session, l10n, DI, API client; poultry/cows slices as structural templates
4. **Endpoints**: same crop-names / crop-cycles / expenses / harvests / summary contract as web
5. **ADRs to honor (UI only)**: ADR-004 archive write-block; ADR-007 active crop-name uniqueness

## Technical Approach

1. **Domain entities** mirror API snake_case fields as Dart types (expense `category` enum)
2. **`CropsRepository`** port + Dio-backed impl using existing authenticated client
3. **Presentation**: follow poultry/cows presentation patterns (StatefulWidget / Cubit as used there)
4. **Navigation**: `/crops`, `/crops/names`, `/crops/names/new`, `/crops/names/:id`, `/crops/cycles/new`, `/crops/cycles/:id` under authenticated shell; home/shell entry to Crops
5. **Localization**: add crops-related keys to `app_en.arb` / `app_bn.arb`; regenerate localizations
6. **Errors**: map `AppFailure` / API error body to SnackBar or inline banner using `message`
7. **Suggested units**: optional fetch of `/api/v1/config/suggested-units` for harvest unit hints
8. **Expense categories**: labour | fertilizers | pesticides_and_chemicals | seeds | irrigation | equipment | other

## Out of Scope

- Web changes
- Unarchive / expense/harvest edit/delete / multi-farm
- Store release / CI signing

## Acceptance Criteria

- [x] Signed-in owner can list active crop cycles and open detail on mobile
- [x] Owner can list/create/edit/archive crop names; duplicate active name shows API message
- [x] Owner can create/edit/archive cycles using active catalog picker
- [x] Owner can add/list expenses and harvests; detail shows summary (expenses, sale income, result)
- [x] Archived name/cycle: readable and write-blocked
- [x] Crops UI strings available in English and Bangla
- [x] API errors show user-facing `message` consistently with auth/cows/poultry/web
- [x] Critical-path tests pass

## Relevant Prior Decisions

- ADR-004, ADR-007 constrain lifecycle/uniqueness the UI must respect
- Mobile auth session/refresh unchanged from platform mobile bolt
- Poultry mobile feature (`009-poultry`) is the closest structural template (parent + child records + archive)
