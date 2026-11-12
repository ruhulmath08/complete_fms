---
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
phase: inception
status: ready
created: "2026-11-12T07:34:21Z"
updated: "2026-11-12T07:34:21Z"
unit_type: mobile
default_bolt_type: simple-construction-bolt
---

# Unit Brief: 003-design-mobile

## Purpose

Deliver a production-ready Flutter mobile experience: usable navigation chrome, mirrored tokens/states, detail/history visual parity with pagination, totals/actions/cow layout parity, and practical forms/a11y.

## Scope

### In Scope

- Replace crowded AppBar nav with phone-ready pattern
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

**Parity stories (owned by web FRs, delivered here):** FR-1, FR-5, FR-6, FR-8, FR-9, FR-12, FR-13, FR-14, FR-15

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
- Prefer drawer if owner unspecified

---

## Success Criteria

- [ ] Phone-usable nav to all destinations in ≤ 2 taps
- [ ] Detail/history feel production-ready with pagination
- [ ] Totals + edit/delete + cow layout parity with web intent
- [ ] Shared empty/loading/error used on primary lists
