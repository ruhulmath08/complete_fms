---
id: 003-mobile-ledger-range-graph
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 034-ops-calc-mobile
implemented: false
---

# Story: 003-mobile-ledger-range-graph

## User Story

**As a** farm owner  
**I want** numeric ledger totals and a graph after Apply date range on mobile  
**So that** I can see exact amounts and trends

## Acceptance Criteria

- [ ] **Given** a valid date range, **When** I apply it, **Then** numeric Total income, Total expenses, and Net update
- [ ] **Given** the same apply, **When** the page updates, **Then** a graph below the apply control reflects income, expenses, and net
- [ ] **Given** an empty range, **When** I apply, **Then** UI stays error-free

## Technical Notes

- Keep numeric totals; add chart consuming ledger series API; EN/BN

## Dependencies

### Requires
- `003-api-ledger-range-series`

### Enables
- None

## Out of Scope

- Replacing ledger list CRUD
