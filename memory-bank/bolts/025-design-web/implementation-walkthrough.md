---
unit: 002-design-web
bolt: 025-design-web
stage: implement
status: complete
updated: "2026-11-12T08:42:00Z"
---

# Implementation Walkthrough - 025-design-web

## Summary

Polished the signed-in shell and converted primary entity lists to Milk-style paginated tables with shared empty/loading/error primitives (default page size 10).

## Changes

### Shell / tokens (story 001)

- Skip link → `#main-content`
- Mobile scrim (≤800px) when sidebar open; main content non-interactive behind drawer
- Escape closes profile menu → notifications → sidebar (focus returns to trigger)
- Shared `:focus-visible` / `--focus-ring` / `--scrim-bg` tokens

### Shared UI (stories 002–003)

- `DEFAULT_PAGE_SIZE = 10`
- `PaginationControls` in `shared/ui` (cows feature re-exports)
- `LoadingState`, `EmptyState` (optional CTA)
- Existing `ErrorBanner` retained (`role="alert"`)

### List pages (story 002)

Milk-style `table table-striped table-bordered` + offset pagination on:

- Cows, Poultry, Crop cycles, Crop names, Inventory, Ledger

## Story mapping

| Story | Delivered |
|-------|-----------|
| 001-web-tokens-and-shell-polish | Skip, scrim, Escape, focus-visible |
| 002-web-universal-paginated-tables | All primary lists + shared pagination |
| 003-web-empty-loading-error | LoadingState / EmptyState / ErrorBanner on lists |

## Verification

```bash
cd web && npm test -- --run
# 31 passed
```

## Out of scope / follow-ups

- Action/Total columns, cow detail chrome, Back removal (bolt 026)
- Poultry egg/feeding Milk-style tables (optional parity; cow milk/feeding already paginated)
