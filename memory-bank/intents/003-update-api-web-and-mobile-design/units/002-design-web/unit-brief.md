---
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
phase: inception
status: complete
created: '2026-11-12T07:34:21Z'
updated: '2026-11-12T07:34:21Z'
unit_type: web
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 002-design-web

## Purpose

Deliver a production-ready React web experience: polished shell, universal Milk-style paginated tables with Total and Action columns, cow detail layout, refreshed Edit/Archive, shared states, a11y, and developer pattern docs.

## Scope

### In Scope

- Visual tokens and shell polish (drawer/scrim, focus, skip link)
- Universal paginated tables across entity lists and histories
- Empty/loading/error primitives
- Total + Action (Edit/Delete icons) on data tables
- Cow detail: rectangular image left, info right; remove Back links; Edit/Archive refresh
- Forms/a11y pass and short developer docs

### Out of Scope

- Mobile UI (unit `003-design-mobile`)
- API implementation (unit `001-design-api`)

---

## Assigned Requirements

| FR    | Requirement                    | Priority |
| ----- | ------------------------------ | -------- |
| FR-1  | Production-ready visual system | Must     |
| FR-2  | Web shell polish               | Must     |
| FR-4  | Universal data tables          | Must     |
| FR-5  | Empty/loading/error states     | Must     |
| FR-6  | Pagination parity              | Must     |
| FR-8  | Form/filter consistency        | Should   |
| FR-9  | Practical a11y                 | Must     |
| FR-11 | Developer design docs          | Should   |
| FR-12 | Row Total columns              | Must     |
| FR-13 | Action Edit/Delete             | Must     |
| FR-14 | Cow image left / info right    | Must     |
| FR-15 | Remove Back links              | Must     |
| FR-16 | Refresh Edit/Archive           | Must     |

---

## Domain Concepts

### Key Entities

| Entity     | Description                      | Attributes                           |
| ---------- | -------------------------------- | ------------------------------------ |
| AppShell   | Signed-in chrome                 | sidebar, header, footer              |
| DataTable  | Paginated table pattern          | columns, Action, Total, page size 10 |
| PageLayout | Shared list/detail page scaffold | toolbar, body, states                |

### Key Operations

| Operation         | Description                  | Inputs   | Outputs       |
| ----------------- | ---------------------------- | -------- | ------------- |
| Render table page | List/history with pagination | API page | Table UI      |
| Edit/Delete row   | Action column flows          | row id   | Updated table |
| Show cow detail   | Image+info layout            | cow      | Detail chrome |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 6     |
| Must Have     | 5     |
| Should Have   | 1     |
| Could Have    | 0     |

### Stories

- [x] **001-web-tokens-and-shell-polish**: Tokens + shell polish - Must - Planned
- [x] **002-web-universal-paginated-tables**: Universal paginated tables - Must - Planned
- [x] **003-web-empty-loading-error**: Empty/loading/error - Must - Planned
- [x] **004-web-table-totals-and-actions**: Totals + Action column - Must - Planned
- [x] **005-web-cow-detail-chrome**: Cow layout, Back removal, Edit/Archive - Must - Planned
- [x] **006-web-forms-a11y-docs**: Forms, a11y, developer docs - Should - Planned

---

## Dependencies

### Depends On

- `001-design-api` for totals, update/delete, pagination (shell/tokens may start earlier)

### Depended On By

- None

---

## Technical Constraints

- Extend intent `002` AppShell/tokens/tables where possible
- Bootstrap-style tables consistent with Milk production
- Page size default 10

---

## Success Criteria

- [ ] All primary lists/histories are paginated tables
- [ ] Feeding has Total; Action Edit/Delete on data tables
- [ ] Cow detail image left / info right; no Back links; Edit/Archive refreshed
- [ ] Shell usable on narrow viewports with a11y basics
