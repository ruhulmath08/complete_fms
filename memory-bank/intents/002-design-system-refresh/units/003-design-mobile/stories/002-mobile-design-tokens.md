---
id: 002-mobile-design-tokens
unit: 003-design-mobile
intent: 002-design-system-refresh
status: complete
priority: should
created: '2026-11-11T18:01:56Z'
assigned_bolt: 022-design-mobile
implemented: true
---

# Story: 002-mobile-design-tokens

## User Story

**As a** developer  
**I want** mirrored design tokens on Flutter  
**So that** brand color and spacing stay aligned with the web refresh where practical

## Acceptance Criteria

- [ ] **Given** the mobile theme, **When** brand accents are applied, **Then** primary green `#2f6a3a` (or token equivalent) is defined centrally rather than scattered magic numbers
- [ ] **Given** list cards and cow form chrome, **When** they use theme tokens, **Then** colors/typography remain consistent across those screens
- [ ] **Given** web vs mobile, **When** layouts differ, **Then** that is acceptable — tokens matter more than identical structure

## Technical Notes

- ThemeExtension / ColorScheme updates in Flutter app theme

## Dependencies

### Requires

- 001-mobile-list-cards

### Enables

- 003-mobile-cow-create-refresh

## Edge Cases

| Scenario                     | Expected Behavior                      |
| ---------------------------- | -------------------------------------- |
| Dark/light themes if present | Tokens apply without breaking contrast |

## Out of Scope

- Cloning the web left sidebar onto mobile
