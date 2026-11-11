---
id: 001-mobile-list-cards
unit: 003-design-mobile
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 022-design-mobile
implemented: false
---

# Story: 001-mobile-list-cards

## User Story

**As a** farm owner  
**I want** mobile list items shown as cards  
**So that** browsing farm records is clearer on a phone

## Acceptance Criteria

- [ ] **Given** I open cows, poultry, crops, inventory, or income/expenses lists on mobile, **When** items render, **Then** each item uses a card-style layout
- [ ] **Given** a card, **When** I tap it, **Then** I navigate to the existing detail/create flow for that item
- [ ] **Given** an empty list, **When** I open the screen, **Then** I see a clear empty state

## Technical Notes

- Reuse a shared card widget where practical across feature modules

## Dependencies

### Requires

- None

### Enables

- 002-mobile-design-tokens

## Edge Cases

| Scenario    | Expected Behavior                             |
| ----------- | --------------------------------------------- |
| Long titles | Ellipsis or wrap without breaking card layout |

## Out of Scope

- Web table layouts
