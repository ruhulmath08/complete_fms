---
id: 004-mobile-totals-actions-cow-layout
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 028-design-mobile
implemented: false
---

# Story: 004-mobile-totals-actions-cow-layout

## User Story

**As a** farm owner
**I want** totals, edit/delete on history rows, and cow image left / info right on mobile
**So that** mobile matches the production web behaviors where practical

## Acceptance Criteria

- [ ] **Given** feeding (and milk) history rows, **When** shown, **Then** Total is visible when meaningful
- [ ] **Given** history rows, **When** shown, **Then** Edit and Delete affordances are available (icons or equivalent) with confirmation on delete
- [ ] **Given** API update/delete, **When** used, **Then** the list refreshes after success
- [ ] **Given** cow detail with image, **When** opened, **Then** rectangular image is left (or top-leading) with info beside/following in a clear two-region layout
- [ ] **Given** archived/read-only, **When** viewing, **Then** mutations are disabled consistently

## Technical Notes

- Requires API update/delete and feeding total

## Dependencies

### Requires

- 001-api-feeding-total-and-list-meta
- 002-api-milk-feeding-update-delete
- 003-mobile-detail-history-pagination

### Enables

- Mobile production parity for FR-12/13/14

## Edge Cases

| Scenario     | Expected Behavior                                       |
| ------------ | ------------------------------------------------------- |
| Narrow phone | Image/info may stack but remain ordered image then info |

## Out of Scope

- Web Action column implementation
