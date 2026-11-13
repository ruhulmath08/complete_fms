---
id: 001-api-crop-expense-harvest-update-delete
unit: 001-ops-calc-api
intent: 005-resolve-operations-and-calculations-issue
status: draft
priority: must
created: '2026-11-13T07:00:00Z'
assigned_bolt: 032-ops-calc-api
implemented: false
---

# Story: 001-api-crop-expense-harvest-update-delete

## User Story

**As a** farm owner  
**I want** the API to update and delete crop expense and harvest rows  
**So that** web and mobile Action columns can maintain crop history after insert

## Acceptance Criteria

- [ ] **Given** an active crop cycle I own, **When** I PATCH an expense, **Then** allowed fields update and the response returns the row
- [ ] **Given** an expense I own, **When** I DELETE it, **Then** I get `204` and the row is hard-deleted
- [ ] **Given** an active crop cycle I own, **When** I PATCH a harvest, **Then** allowed fields update and the response returns the row
- [ ] **Given** a harvest I own, **When** I DELETE it, **Then** I get `204` and the row is hard-deleted
- [ ] **Given** archived cycle or cross-owner id / no token, **When** I mutate, **Then** the API rejects consistently with cow module conventions

## Technical Notes

- Mirror cow milk/feeding and poultry egg/feeding PATCH/DELETE patterns in the crops module

## Dependencies

### Requires
- None

### Enables
- Web/mobile crop Action stories

## Out of Scope

- Soft-delete; UI
