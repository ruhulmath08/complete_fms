---
stage: plan
bolt: 018-income-expenses
created: 2026-11-09T13:28:23Z
---

# Implementation Plan: Income and Expenses (Mobile)

## Objective

Extend the existing Flutter app so a signed-in owner can manage general ledger entries, filter by date, and view period totals against `/api/v1/ledger-entries`, with Bangla and English strings, matching the web ledger workflows from bolt `017-income-expenses`.

## Story in Scope

- **003-mobile-income-and-expenses**: Mobile ledger entries / date views / totals with EN+BN localization

## Deliverables

1. Clean Architecture ledger slice under `mobile/lib/`:
   - `domain/` — ledger entry / period totals entities, repository port, use cases
   - `data/` — API datasource, mappers, repository impl
   - `presentation/income_expenses/` (or `ledger/`) — screens (list with totals/filters, create, detail)
2. Wire into existing GoRouter (protected shell), GetIt DI, Dio client with Bearer + refresh
3. Screens parity with web:
   - Active entries list; include-archived toggle; from/to date filters
   - Period totals (total_income, total_expenses, net) for selected range
   - Create/edit entry (entry_type, occurred_at, category, amount, unit?, note?)
   - Detail: view/edit/archive; show amount + total_price; archived read-only
4. Surface API `message` via existing failure patterns; honor `LEDGER_ENTRY_ARCHIVED`
5. ARB strings for ledger screens in `en` and `bn`
6. Critical-path tests (mappers and/or l10n)

## Dependencies

1. **`016-income-expenses` (API)** — complete
2. **`017-income-expenses` (Web)** — complete (UX/contract reference)
3. **Mobile platform + inventory/crops** — app shell, session, l10n, DI, API client
4. **Endpoints**: same ledger-entries / totals contract as web
5. **ADRs to honor (UI only)**: ADR-004 archive write-block

## Technical Approach

1. **Domain entities** mirror API fields (`EntryType`, `EntryCategory`)
2. **`LedgerRepository`** port + Dio-backed impl
3. **Presentation**: follow inventory/crops StatefulWidget + getIt use-case pattern
4. **Navigation**: `/ledger`, `/ledger/new`, `/ledger/:entryId`; home/shell entry
5. **Localization**: ARB keys in `app_en.arb` / `app_bn.arb`; `flutter gen-l10n`
6. **Errors**: `AppFailure.message` inline / SnackBar
7. **Guidance**: crop-cycle costs stay in Crops module (copy/note in UI)

## Out of Scope

- Web changes
- Unarchive; importing crop expenses
- Store release / CI signing

## Acceptance Criteria

- [x] Signed-in owner can list ledger entries and open detail on mobile
- [x] Owner can create/edit/archive entries; filter by date; view period totals
- [x] Archived entry: readable and write-blocked
- [x] Ledger UI strings in English and Bangla
- [x] Critical-path tests pass

## Relevant Prior Decisions

- ADR-004 constrains archive behavior
- Mobile auth session/refresh unchanged
- `amount` is money; `total_price` equals amount on read (API from 016)
- Inventory mobile feature is a close structural template
