---
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
phase: inception
status: ready
created: "2026-11-12T07:34:21Z"
updated: "2026-11-12T08:36:33Z"
unit_type: mobile
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 003-design-mobile

## Purpose

Deliver a production-ready Flutter mobile experience: navigation drawer + TitleBar ⋮ (Profile/Logout dialog), mirrored tokens/states, detail/history visual parity with pagination, totals/actions/cow layout parity, and practical forms/a11y.

## Scope

### In Scope

- **Navigation drawer** on landing/shell: Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings
- TitleBar **three-dot** overflow: Profile and Logout (icon+title); Logout confirm/cancel alert dialog
- Mirror visual tokens and empty/loading/error primitives
- Detail/history visual system + pagination for milk/feeding and similar
- Totals, edit/delete affordances, cow image/info layout parity
- Forms/a11y; remove Back-style links if present

### Out of Scope

- Web UI (unit `002-design-web`)
- API implementation (unit `001-design-api`)

---

## Assigned Requirements

| FR   | Requirement                             | Priority |
| ---- | --------------------------------------- | -------- |
| FR-3 | Mobile navigation chrome refresh        | Must     |
| FR-7 | Mobile detail and history visual parity | Must     |

**Also delivered here (Must on mobile, not optional parity):** FR-12 (totals / feeding unit cost), FR-13 (Edit/Delete on milk & feeding), FR-14 (cow image left / info right)

**Additional parity stories:** FR-1, FR-5, FR-6, FR-8, FR-9, FR-15

---

## Domain Concepts

### Key Entities

| Entity         | Description             | Attributes                      |
| -------------- | ----------------------- | ------------------------------- |
| AppShell       | Signed-in mobile chrome | drawer/bottom nav, active route |
| HistorySection | Paginated history UI    | rows, totals, actions           |
| EntityDetail   | Detail layout           | image + info                    |

### Key Operations

| Operation        | Description            | Inputs | Outputs      |
| ---------------- | ---------------------- | ------ | ------------ |
| Navigate domains | Reach all destinations | tap    | Route        |
| Page history     | Load next page         | offset | Rows         |
| Edit/Delete row  | Mutate history entry   | id     | Updated list |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 5     |
| Must Have     | 4     |
| Should Have   | 1     |
| Could Have    | 0     |

### Stories

- [ ] **001-mobile-nav-chrome**: Mobile navigation chrome - Must - Planned
- [ ] **002-mobile-tokens-and-states**: Tokens + empty/loading/error - Must - Planned
- [ ] **003-mobile-detail-history-pagination**: Detail/history + pagination - Must - Planned
- [ ] **004-mobile-totals-actions-cow-layout**: Totals, actions, cow layout - Must - Planned
- [ ] **005-mobile-forms-a11y**: Forms + a11y - Should - Planned

---

## Dependencies

### Depends On

- `001-design-api` for totals, update/delete, pagination (nav/tokens may start earlier)

### Depended On By

- None

---

## Technical Constraints

- Material 3 + existing `AppTokens`
- BN/EN l10n for new strings
- Navigation pattern is **drawer + AppBar overflow** (not bottom-nav-primary)

---

## Success Criteria

- [ ] Drawer lists required destinations; TitleBar ⋮ offers Profile + Logout with confirm dialog
- [ ] Detail/history feel production-ready with pagination
- [ ] Milk/feeding show Total (+ feeding unit cost) and Edit/Delete wired to bolt 024 APIs
- [ ] Cow detail rectangular image + info layout matches production web intent
- [ ] Shared empty/loading/error used on primary lists
