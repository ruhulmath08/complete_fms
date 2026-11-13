---
id: 001-web-crop-expense-harvest-actions
unit: 002-ops-calc-web
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 033-ops-calc-web
implemented: false
---

# Story: 001-web-crop-expense-harvest-actions

## User Story

**As a** farm owner  
**I want** Edit and Delete actions on crop Expenses and Harvests tables  
**So that** I can maintain crop history on web like cows

## Acceptance Criteria

- [ ] **Given** expense rows on a crop cycle, **When** I edit and save, **Then** the table shows updated values
- [ ] **Given** an expense row, **When** I delete and confirm, **Then** the row is removed
- [ ] **Given** harvest rows, **When** I edit or delete with confirm, **Then** the table updates accordingly
- [ ] **Given** Action controls, **When** I view them, **Then** Edit uses primary styling and Delete uses danger styling

## Technical Notes

- Reuse cow/poultry Action column patterns from intents `003`/`004`

## Dependencies

### Requires
- `001-api-crop-expense-harvest-update-delete`

### Enables
- None

## Out of Scope

- Soft-delete
