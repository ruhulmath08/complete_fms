---
id: 005-mobile-forms-a11y
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: complete
priority: should
created: "2026-11-12T07:34:21Z"
assigned_bolt: 028-design-mobile
implemented: true
---

# Story: 005-mobile-forms-a11y

## User Story

**As a** farm owner
**I want** consistent forms and practical semantics on key controls
**So that** mobile input and accessibility match the production bar

## Acceptance Criteria

- [ ] **Given** primary create/edit forms, **When** shown, **Then** required fields have visible labels
- [ ] **Given** date filters/fields, **When** used, **Then** appropriate date controls are used where practical
- [ ] **Given** primary nav and list cards, **When** inspected for a11y, **Then** Semantics (or equivalent) labels exist on key actions
- [ ] **Given** new user-visible strings, **When** added, **Then** they go through BN/EN l10n

## Technical Notes

- Practical a11y, not a full audit

## Dependencies

### Requires

- 001-mobile-nav-chrome
- 002-mobile-tokens-and-states

### Enables

- NFR-6 / FR-8/9 mobile parity

## Edge Cases

| Scenario         | Expected Behavior                       |
| ---------------- | --------------------------------------- |
| Validation error | Inline/error pattern consistent per app |

## Out of Scope

- Web forms
