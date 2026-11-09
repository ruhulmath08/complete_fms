---
stage: implement
bolt: 017-income-expenses
created: 2026-11-09T13:25:55Z
---

# Implementation Walkthrough: Income and Expenses (Web)

## Summary

Added general ledger management to the React SPA: list/create/edit/archive entries with date-range filters and period totals under protected routes, using shared API client and ErrorBanner patterns.

## Structure Overview

New feature folder `web/src/features/income-expenses` with types, API wrappers, entry form, and list/create/detail pages. List hosts date filters and totals. App shell nav and home CTA point to `/ledger`.

## Completed Work

- [x] Types + `ledgerApi.ts`
- [x] `LedgerEntryForm` (type, date, category, amount, optional unit/note)
- [x] List / create / detail pages with archive write-block
- [x] Routes `/ledger`, `/ledger/new`, `/ledger/:entryId`
- [x] AppShell + HomePage CTAs
- [x] Vitest: list success + totals; list error banner

## Key Decisions

- **Routes under `/ledger`** matching API resource naming
- **Default date range** = current calendar month for list + totals
- **Crop guidance** note on create form; totals from ledger API only

## Deviations from Plan

None material. Stage 3 test walkthrough still pending.

## Developer Notes

- `npm test -- --run src/features/income-expenses` and `npm run build` verified
