---
id: 001-mobile-nav-chrome
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 027-design-mobile
implemented: false
---

# Story: 001-mobile-nav-chrome

## User Story

**As a** farm owner
**I want** phone-friendly navigation instead of a crowded AppBar of text buttons
**So that** I can reach every domain without overflow or confusion

## Acceptance Criteria

- [ ] **Given** a signed-in session, **When** I open the shell, **Then** I can reach Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings, and Sign out in ≤ 2 taps
- [ ] **Given** a typical phone width, **When** viewing nav, **Then** destination labels do not horizontally overflow
- [ ] **Given** the current route, **When** nav is shown, **Then** the active destination is visually indicated
- [ ] **Given** shared tokens, **When** nav is styled, **Then** it uses the production token set

## Technical Notes

- Prefer Material 3 drawer if unspecified; bottom nav acceptable if it fits destinations

## Dependencies

### Requires

- None

### Enables

- Rest of mobile production UX

## Edge Cases

| Scenario           | Expected Behavior               |
| ------------------ | ------------------------------- |
| Long Bangla labels | Still readable without overflow |

## Out of Scope

- Web sidebar changes
