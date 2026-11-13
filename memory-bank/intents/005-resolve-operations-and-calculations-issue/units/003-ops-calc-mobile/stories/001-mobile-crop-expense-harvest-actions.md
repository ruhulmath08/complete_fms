---
id: 001-mobile-crop-expense-harvest-actions
unit: 003-ops-calc-mobile
intent: 005-resolve-operations-and-calculations-issue
status: complete
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 034-ops-calc-mobile
implemented: true
---

# Story: 001-mobile-crop-expense-harvest-actions

## User Story

**As a** farm owner  
**I want** Edit and Delete on crop Expenses and Harvests on mobile  
**So that** I can maintain crop history like cows

## Acceptance Criteria

- [ ] **Given** expense rows, **When** I edit and save, **Then** the list/table shows updated values
- [ ] **Given** an expense row, **When** I delete and confirm, **Then** the row is removed
- [ ] **Given** harvest rows, **When** I edit or delete with confirm, **Then** history updates accordingly
- [ ] **Given** Action controls, **When** I view them, **Then** Edit is primary and Delete is danger

## Technical Notes

- Mirror poultry/cow mobile Action patterns; EN/BN strings as needed

## Dependencies

### Requires
- `001-api-crop-expense-harvest-update-delete`

### Enables
- None

## Out of Scope

- Soft-delete
