---
unit: 003-design-mobile
intent: 002-design-system-refresh
phase: inception
status: ready
created: 2026-11-11T18:01:56Z
updated: 2026-11-11T18:01:56Z
unit_type: mobile
default_bolt_type: simple-construction-bolt
---

# Unit Brief: Design Mobile

## Purpose

Refresh Flutter mobile list presentation to card layouts, mirror practical design tokens (including primary green `#2f6a3a` where used), and update cow create/detail to Weight (kg), cow image, and API-generated tag numbers.

## Scope

### In Scope

- Card layouts for cows, poultry, crops, inventory, income/expenses lists
- Mirrored design tokens where practical
- Cow create/detail: cow image, Weight (kg), consume auto tag (no manual inventing of tag)
- Keep existing navigation patterns unless a small chrome tweak is needed for consistency

### Out of Scope

- React web shell/tables
- API implementation
- Full notification system

---

## Assigned Requirements

| FR   | Requirement                | Priority |
| ---- | -------------------------- | -------- |
| FR-2 | Mobile list items as cards | Must     |

**Parity stories** (support FR-3 / FR-4 / FR-9 UX on mobile without reassigning those FRs):

- Cow image, Weight (kg), auto-tag consumption, token mirroring

---

## Domain Concepts

### Key Entities

| Entity   | Description               | Attributes                         |
| -------- | ------------------------- | ---------------------------------- |
| ListCard | Card row for entity lists | title, subtitle, tap target        |
| CowForm  | Create/edit cow           | image, weight label, generated tag |

### Key Operations

| Operation    | Description                    | Inputs     | Outputs    |
| ------------ | ------------------------------ | ---------- | ---------- |
| Browse lists | Card-based lists               | API list   | cards      |
| Create cow   | Image + labels + generated tag | form + API | cow detail |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 4     |
| Must Have     | 3     |
| Should Have   | 1     |
| Could Have    | 0     |

### Stories

| Story ID                              | Title                             | Priority | Status  |
| ------------------------------------- | --------------------------------- | -------- | ------- |
| 001-mobile-list-cards                 | Mobile list cards                 | Must     | Planned |
| 002-mobile-design-tokens              | Mobile design tokens              | Should   | Planned |
| 003-mobile-cow-create-refresh         | Mobile cow create refresh         | Must     | Planned |
| 004-mobile-consume-auto-tag-and-image | Mobile consume auto tag and image | Must     | Planned |

---

## Dependencies

### Depends On

| Unit           | Reason                           |
| -------------- | -------------------------------- |
| 001-design-api | Auto tag and cow image contracts |

### Depended By

| Unit | Reason |
| ---- | ------ |
| —    | —      |

---

## Technical Constraints

- Flutter Clean Arch + BLoC patterns already in repo
- Mirror `#2f6a3a` where brand accent is used; layouts need not match web sidebar

## Success Criteria

- [ ] Primary domain lists use cards
- [ ] Cow create shows image + Weight (kg) and uses generated tag
- [ ] Tokens applied where practical
