---
id: 002-web-fertilizer-stock-table
unit: 002-ops-calc-web
intent: 005-resolve-operations-and-calculations-issue
status: complete
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 033-ops-calc-web
implemented: true
---

# Story: 002-web-fertilizer-stock-table

## User Story

**As a** farm owner  
**I want** fertilizer-category stock changes shown as a table like cow history  
**So that** I can review all fertilizer stock updates clearly on web

## Acceptance Criteria

- [ ] **Given** fertilizer-category stock updates, **When** I open the fertilizer stock history UI, **Then** I see a paginated table with readable columns
- [ ] **Given** non-fertilizer stock updates, **When** I view this table, **Then** they are not listed
- [ ] **Given** empty fertilizer stock history, **When** I open the table, **Then** I see an empty state without errors

## Technical Notes

- Wire to fertilizer-category stock list API; Action column if mutations ship in API bolt

## Dependencies

### Requires
- `002-api-fertilizer-stock-list`

### Enables
- None

## Out of Scope

- Redesigning other inventory category UIs beyond shared table reuse
