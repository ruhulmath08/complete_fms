---
stage: plan
bolt: 017-income-expenses
created: 2026-11-09T13:23:22Z
---

# Implementation Plan: Income and Expenses (Web)

## Objective

Add signed-in general ledger workflows to the existing React (Vite) SPA so the owner can manage income/expense entries, filter by date, and view period totals against the completed `/api/v1/ledger-entries` contract from bolt `016-income-expenses`.

## Story in Scope

- **002-web-income-and-expenses**: Entries, date views, and period totals in the browser using shared API error handling

## Deliverables

1. Feature module under `web/src/features/income-expenses` (API client, types, pages/components)
2. Typed DTOs and TanStack Query usage against:
   - `GET|POST /api/v1/ledger-entries`, `GET|PATCH /api/v1/ledger-entries/{id}`, `POST .../archive`
   - `GET /api/v1/ledger-entries/totals?from=&to=`
3. Screens/routes (protected, inside `AppShell`):
   - Entries list (+ create; include-archived toggle; optional from/to date filters)
   - Entry create form (entry_type, occurred_at, category, amount, unit?, note?)
   - Entry detail: view/edit/archive; show amount + total_price (same value); hide writes when archived
   - Period totals panel (from/to + total_income / total_expenses / net) on list or dedicated section
4. Reuse `apiClient`, `ErrorBanner` / `ApiError` (`message` + `code`); surface `LEDGER_ENTRY_ARCHIVED`
5. Nav link to Income & Expenses from `AppShell`; home CTA alongside inventory/crops/etc.
6. Critical-path Vitest (list success/error and/or totals / form patterns)

## Dependencies

1. **`016-income-expenses` (API)** — complete; OpenAPI at backend `/docs`
2. **`014-inventory` / `011-crops` (web)** — SPA patterns to mirror
3. **ADRs**: ADR-004 archive write-block

## Technical Approach

1. **Types** in `web/src/features/income-expenses/types.ts` (entry_type + category enums matching API)
2. **`ledgerApi.ts`**: thin authenticated wrappers
3. **Routes**: `/ledger` (or `/income-expenses`), `/ledger/new`, `/ledger/:entryId`
4. **UX**: confirm archive; hide writes when archived; category + type selects; show totals for selected range; note that crop-cycle expenses stay in Crops module
5. **Styling**: reuse existing CSS / form / list patterns

## Out of Scope

- Flutter (018-income-expenses)
- Unarchive; hard delete; importing crop expenses
- Bangla web localization
- Hosting

## Acceptance Criteria

- [x] Owner can list/create/edit/archive ledger entries
- [x] Owner can filter list by date range and view period totals
- [x] Archived entry: no write actions; API errors surfaced via shared banner
- [x] Critical-path Vitest passes

## Relevant Prior Decisions

- ADR-004 constrains UI behavior
- Web auth session unchanged
- `amount` is money; `total_price` equals amount on read (API contract from 016)
