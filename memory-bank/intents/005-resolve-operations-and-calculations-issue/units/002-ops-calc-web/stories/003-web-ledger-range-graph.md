---
id: 003-web-ledger-range-graph
unit: 002-ops-calc-web
intent: 005-resolve-operations-and-calculations-issue
status: complete
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 033-ops-calc-web
implemented: true
---

# Story: 003-web-ledger-range-graph

## User Story

**As a** farm owner  
**I want** numeric Total income, Total expenses, and Net plus a graph after Apply date range  
**So that** I can see exact amounts and trends on web

## Acceptance Criteria

- [ ] **Given** a valid date range, **When** I apply it, **Then** numeric Total income, Total expenses, and Net update
- [ ] **Given** the same apply, **When** the page updates, **Then** a graph below the apply control reflects income, expenses, and net for the range
- [ ] **Given** an empty range, **When** I apply, **Then** numeric zeros/empty and graph remain error-free

## Technical Notes

- Keep existing numeric totals; add chart component consuming ledger series/totals API

## Dependencies

### Requires
- `003-api-ledger-range-series`

### Enables
- None

## Out of Scope

- Replacing the ledger entry list itself
