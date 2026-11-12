---
stage: plan
bolt: 025-design-web
created: "2026-11-12T08:39:00Z"
---

# Implementation Plan: 025-design-web

## Objective

Ship web foundation for production design: shell polish (scrim, Escape, focus-visible, skip link), universal Milk-style paginated tables (page size 10), and shared empty/loading/error states.

## Stories in Scope

- **001-web-tokens-and-shell-polish**
- **002-web-universal-paginated-tables**
- **003-web-empty-loading-error**

## Deliverables

1. AppShell polish: skip link → `#main-content`, mobile scrim when sidebar open (≤800px), Escape closes sidebar/popovers with sensible focus return, chrome `:focus-visible`
2. Shared primitives: `DEFAULT_PAGE_SIZE=10`, shared `PaginationControls`, `LoadingState`, `EmptyState` (extend `ErrorBanner` as needed)
3. Primary list pages (cows, poultry, crops cycles/names, inventory, ledger) as Milk-style bordered/striped tables with offset pagination
4. Cow milk/feeding keep shared pagination import; Vitest coverage for shell a11y + list paging/states

## Technical Approach

1. Tokens/CSS: scrim, skip-link, focus-visible for shell controls; reuse existing table CSS
2. Move/generalize `PaginationControls` to `shared/ui`; re-export or update cow imports
3. Add `LoadingState` / `EmptyState`; wire lists to shared primitives
4. Refactor each `*ListPage` from `record-list`/`limit:100` to table + `limit:10` + pagination from `meta`
5. Tests: AppShell Escape/skip/scrim; at least one list pagination + empty/loading/error path

## Out of Scope

- Action/Total columns and cow detail chrome (bolt 026)
- Mobile Flutter (027–028)
- Soft-delete / new API contracts beyond 024

## Acceptance Criteria

- [ ] Shell: tokens + scrim + Escape + focus-visible + skip link
- [ ] All primary entity lists are paginated Milk-style tables (default 10)
- [ ] Shared loading/empty/error used on primary lists
- [ ] Critical-path Vitest passes
