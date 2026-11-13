---
id: 004-api-dashboard-aggregates
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 032-ops-calc-api
implemented: false
---

# Story: 004-api-dashboard-aggregates

## User Story

**As a** farm owner  
**I want** dashboard aggregates for egg production, hen headcount, milk, cow production, expenses/cost, and income over a period  
**So that** web and mobile Dashboard graphs can load safely without future dates

## Acceptance Criteria

- [ ] **Given** a period of day/week/month/year within farm local TZ, **When** I request dashboard aggregates, **Then** responses include series (or buckets) for egg production, hen headcount, milk, cow production, expenses/cost, and income
- [ ] **Given** sparse data, **When** I request aggregates, **Then** missing buckets are zero/empty-safe
- [ ] **Given** an end bound after “today” in farm local TZ, **When** I request aggregates, **Then** the API rejects the request
- [ ] **Given** no bearer token, **When** I call the endpoint, **Then** I am unauthorized

## Technical Notes

- Default client period is this week (client); API must accept week bounds and reject future ends
- Clarify cow production vs milk series definitions in technical design
- Farm TZ from farm settings when present; document default if unset

## Dependencies

### Requires
- None

### Enables
- Web/mobile Dashboard stories

## Out of Scope

- Forecasting; multi-farm analytics
