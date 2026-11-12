---
id: 003-mobile-detail-history-pagination
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 028-design-mobile
implemented: true
---

# Story: 003-mobile-detail-history-pagination

## User Story

**As a** farm owner
**I want** detail and history UIs that match the refreshed visual system and paginate like web
**So that** histories are not truncated and screens feel finished

## Acceptance Criteria

- [ ] **Given** cow/poultry/crops/inventory/ledger details, **When** opened, **Then** sections use shared card/surface patterns (not unfinished dense tiles only)
- [ ] **Given** cow milk and feeding histories, **When** more than one page exists, **Then** I can paginate or load more (not first 10 only)
- [ ] **Given** empty/error on histories, **When** shown, **Then** shared state widgets from story 002 are used
- [ ] **Given** any “Back to …” style links on mobile inner pages, **When** this story ships, **Then** they are removed in favor of shell navigation

## Technical Notes

- Consume API pagination meta; page size 10 preferred

## Dependencies

### Requires

- 003-api-entity-list-pagination-parity (and milk/feeding meta)
- 002-mobile-tokens-and-states

### Enables

- Totals/actions story

## Edge Cases

| Scenario          | Expected Behavior         |
| ----------------- | ------------------------- |
| Last page partial | Shows remaining rows only |

## Out of Scope

- Web tables
