---
id: 004-mobile-dashboard-and-landing
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 034-ops-calc-mobile
implemented: false
---

# Story: 004-mobile-dashboard-and-landing

## User Story

**As a** farm owner  
**I want** a Dashboard after login with production and money graphs and period controls on mobile  
**So that** I get a this-week overview without selecting future dates

## Acceptance Criteria

- [ ] **Given** successful mobile sign-in, **When** navigation completes, **Then** I land on Dashboard
- [ ] **Given** Dashboard first load, **When** graphs render, **Then** default period is this week (farm local TZ)
- [ ] **Given** Dashboard, **When** I view graphs, **Then** egg production, hen headcount, milk, cow production, expenses/cost, and income areas are present
- [ ] **Given** day/week/month/year selection, **When** I change period, **Then** graphs refresh
- [ ] **Given** date controls, **When** I try a future date, **Then** UI prevents selection
- [ ] **Given** signed-in shell, **When** I navigate, **Then** Dashboard is reachable; new copy has EN/BN

## Technical Notes

- Update `AppRoutes` / redirect from prior home; consume dashboard aggregates API

## Dependencies

### Requires
- `004-api-dashboard-aggregates`

### Enables
- None

## Out of Scope

- Forecasting UI
