---
title: Web UI patterns
updated: "2026-11-12T08:50:00Z"
---

# Web UI patterns

Short reference for shared React SPA primitives under `web/src`.

## Shell

- `shared/ui/AppShell.tsx` — signed-in chrome (sidebar, header, footer)
- Skip link → `#main-content`; Escape closes menus/drawer; ≤800px scrim when sidebar open
- Tokens live in `web/src/index.css` (`:root`)

## Page layout

- `panel panel-wide` + `page-toolbar` + `toolbar-actions`
- Detail Edit = `btn btn-primary` (ghost while canceling); Archive = `btn btn-danger-ghost`
- Cow detail media/info: `detail-chrome` (image left / info right; stacks on narrow viewports)
- Do **not** add “← Back to …” links; use the shell nav

## Lists & tables

- Default page size: `shared/constants/pagination.ts` → `DEFAULT_PAGE_SIZE` (10)
- Markup: `table-responsive` → `table table-striped table-bordered`
- Pagination: `shared/ui/PaginationControls`
- Row money columns: prefer API `total` when present; otherwise qty × unit price/cost
- Action column (Edit/Delete icons): wire only where PATCH/DELETE APIs exist (cow milk/feeding today); use `.table-actions` + `.btn-icon`

## States

- Loading: `shared/ui/LoadingState`
- Empty: `shared/ui/EmptyState` (optional CTA)
- Error: `shared/ui/ErrorBanner` (`role="alert"`)

## Forms

- `form-stack` / `row-2` / `field` with visible `<label htmlFor>`
- Prefer native `type="date"` / `datetime-local` for filters and records
