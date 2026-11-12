---
id: 002-mobile-tokens-and-states
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 027-design-mobile
implemented: true
---

# Story: 002-mobile-tokens-and-states

## User Story

**As a** farm owner
**I want** consistent tokens and shared empty/loading/error UI on mobile
**So that** the app feels like one product and states are clear

## Acceptance Criteria

- [ ] **Given** primary signed-in screens, **When** styled, **Then** they use shared AppTokens / ThemeData (including typography roles aligned with web where practical)
- [ ] **Given** loading lists, **When** fetching, **Then** a shared loading widget is used
- [ ] **Given** empty lists, **When** shown, **Then** localized empty copy + optional primary action appear
- [ ] **Given** errors, **When** shown, **Then** a shared error presentation is used (not only raw red Text)

## Technical Notes

- Mirror web FR-1/FR-5 patterns; keep BN/EN l10n

## Dependencies

### Requires

- 001-mobile-nav-chrome (preferred)

### Enables

- Detail/history polish

## Edge Cases

| Scenario      | Expected Behavior                 |
| ------------- | --------------------------------- |
| Locale switch | Empty/error strings follow locale |

## Out of Scope

- Web components
