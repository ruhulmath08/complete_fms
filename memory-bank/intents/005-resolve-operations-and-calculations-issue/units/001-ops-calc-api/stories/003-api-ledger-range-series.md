---
id: 003-api-ledger-range-series
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
status: complete
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 032-ops-calc-api
implemented: true
---

# Story: 003-api-ledger-range-series

## User Story

**As a** farm owner  
**I want** ledger date-range data that supports income, expenses, and net as a time series  
**So that** web and mobile can keep numeric totals and render a graph

## Acceptance Criteria

- [ ] **Given** a valid from/to range I own, **When** I request ledger range series (or extended totals), **Then** I can derive income, expenses, and net points/totals for that range
- [ ] **Given** an empty range, **When** I request series/totals, **Then** I get zero-safe empty results without error
- [ ] **Given** no bearer token, **When** I call the endpoint, **Then** I am unauthorized

## Technical Notes

- Prefer extending existing period-totals API or add a dedicated series endpoint if totals-only is insufficient for charts

## Dependencies

### Requires
- None

### Enables
- Web/mobile ledger graph stories

## Out of Scope

- Full BI reporting beyond income/expenses/net for the selected range
