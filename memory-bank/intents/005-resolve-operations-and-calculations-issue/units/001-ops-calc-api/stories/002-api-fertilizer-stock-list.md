---
id: 002-api-fertilizer-stock-list
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
status: complete
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 032-ops-calc-api
implemented: true
---

# Story: 002-api-fertilizer-stock-list

## User Story

**As a** farm owner  
**I want** the API to list stock changes for inventory items in the fertilizer category  
**So that** web and mobile can show a cow-like fertilizer stock history table

## Acceptance Criteria

- [ ] **Given** I own fertilizer-category items with stock updates, **When** I list fertilizer stock changes, **Then** I receive paginated `items` + `meta` covering those updates
- [ ] **Given** stock updates on non-fertilizer items, **When** I list fertilizer stock changes, **Then** those rows are not included
- [ ] **Given** no bearer token, **When** I call the list, **Then** I am unauthorized

## Technical Notes

- Filter by inventory category = fertilizer (all items in category), not a single item name
- Add PATCH/DELETE for stock updates only if client Action requires it in the same bolt

## Dependencies

### Requires
- None

### Enables
- Web/mobile fertilizer stock table stories

## Out of Scope

- Redesigning other inventory categories
