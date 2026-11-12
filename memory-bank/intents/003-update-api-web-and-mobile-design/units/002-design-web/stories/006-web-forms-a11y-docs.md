---
id: 006-web-forms-a11y-docs
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: draft
priority: should
created: "2026-11-12T07:34:21Z"
assigned_bolt: 026-design-web
implemented: false
---

# Story: 006-web-forms-a11y-docs

## User Story

**As a** developer and farm owner
**I want** consistent forms, practical a11y, and short pattern docs
**So that** the UI stays usable and new screens reuse the right primitives

## Acceptance Criteria

- [ ] **Given** primary create/edit forms, **When** rendered, **Then** required fields have visible labels (not placeholder-only)
- [ ] **Given** date filters, **When** used, **Then** native/date controls are used where practical
- [ ] **Given** interactive shell and primary flows, **When** keyboard navigated, **Then** focus is visible and content images have accessible names
- [ ] **Given** developer docs, **When** read, **Then** they list shared primitives for shell, table, Action, empty/loading/error, pagination

## Technical Notes

- Docs may live under `memory-bank/standards` or a short web README section — keep lean

## Dependencies

### Requires

- 001-web-tokens-and-shell-polish
- 002-web-universal-paginated-tables

### Enables

- Developer effectiveness (NFR-3)

## Edge Cases

| Scenario         | Expected Behavior       |
| ---------------- | ----------------------- |
| Decorative image | Marked so AT ignores it |

## Out of Scope

- Full WCAG audit
