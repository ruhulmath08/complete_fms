---
id: 002-mobile-fertilizer-stock-table
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 034-ops-calc-mobile
implemented: false
---

# Story: 002-mobile-fertilizer-stock-table

## User Story

**As a** farm owner  
**I want** fertilizer-category stock changes as a cow-like table on mobile  
**So that** I can review fertilizer stock updates clearly

## Acceptance Criteria

- [ ] **Given** fertilizer-category stock updates, **When** I open the fertilizer stock history UI, **Then** I see a tabular/paginated history with readable columns
- [ ] **Given** non-fertilizer updates, **When** I view this history, **Then** they are not listed
- [ ] **Given** empty history, **When** I open it, **Then** I see an empty state without errors

## Technical Notes

- Wire to fertilizer stock list API; EN/BN copy

## Dependencies

### Requires
- `002-api-fertilizer-stock-list`

### Enables
- None

## Out of Scope

- Full inventory redesign
