---
unit: 002-design-web
intent: 002-design-system-refresh
phase: inception
status: ready
created: 2026-11-11T18:01:56Z
updated: 2026-11-11T18:01:56Z
unit_type: web
default_bolt_type: simple-construction-bolt
---

# Unit Brief: Design Web

## Purpose

Refresh the React (Vite) web app shell and key cow presentation: collapsible left menubar (`#2f6a3a` / white text), header/footer with notification + profile image, design tokens, add-cow image and Weight (kg), Bootstrap milk/feeding tables with pagination, and table-first tabular lists.

## Scope

### In Scope

- App shell: left sidebar nav (Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings), show/hide, header, footer
- Header top-right: notification icon (placeholder OK) + profile image
- Shared web design tokens/components for shell/tables
- Add-cow image + Weight (kg); consume auto tag from API
- Milk Bootstrap table (No, date+time, unit price, total, note; + quantity if needed); feeding aligned table; page size 10
- Prefer tables for other tabular web lists where practical

### Out of Scope

- Flutter mobile UI
- API implementation (consumes `001-design-api`)
- Real notification feed backend

---

## Assigned Requirements

| FR   | Requirement                                  | Priority |
| ---- | -------------------------------------------- | -------- |
| FR-1 | Web app shell — left sidebar, header, footer | Must     |
| FR-3 | Add cow page — cow image and field labels    | Must     |
| FR-5 | Milk production — paginated Bootstrap table  | Must     |
| FR-6 | Feeding — paginated table                    | Must     |
| FR-7 | Prefer tables for tabular data on web        | Should   |
| FR-9 | Shared design tokens / components            | Should   |

---

## Domain Concepts

### Key Entities

| Entity       | Description         | Attributes                         |
| ------------ | ------------------- | ---------------------------------- |
| AppShell     | Signed-in layout    | sidebar, header, footer, tokens    |
| CowForm      | Add/edit cow UI     | image, weight label, read-only tag |
| HistoryTable | Milk/feeding tables | columns, page size 10              |

### Key Operations

| Operation    | Description       | Inputs      | Outputs            |
| ------------ | ----------------- | ----------- | ------------------ |
| Navigate     | Use left menubar  | route       | page               |
| Toggle menu  | Show/hide sidebar | user action | collapsed/expanded |
| View history | Paginated tables  | page        | rows               |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 5     |
| Must Have     | 4     |
| Should Have   | 1     |
| Could Have    | 0     |

### Stories

| Story ID                         | Title                        | Priority | Status  |
| -------------------------------- | ---------------------------- | -------- | ------- |
| 001-web-app-shell                | Web app shell                | Must     | Planned |
| 002-web-design-tokens            | Web design tokens            | Should   | Planned |
| 003-web-add-cow-image-and-labels | Web add cow image and labels | Must     | Planned |
| 004-web-milk-feeding-tables      | Web milk and feeding tables  | Must     | Planned |
| 005-web-tabular-lists            | Web tabular lists            | Should   | Planned |

---

## Dependencies

### Depends On

| Unit           | Reason                                             |
| -------------- | -------------------------------------------------- |
| 001-design-api | Tag generation, cow image, milk/feeding pagination |

### Depended By

| Unit | Reason |
| ---- | ------ |
| —    | —      |

---

## Technical Constraints

- React + Vite; Bootstrap table styling for milk (feeding aligned)
- Menu background `#2f6a3a`, white text
- Do not break first-release workflows

## Success Criteria

- [ ] Shell with show/hide sidebar, header, footer on signed-in pages
- [ ] Add-cow shows image + Weight (kg); tag from API
- [ ] Milk/feeding tables page size 10
- [ ] Tokens used for menu brand colors
