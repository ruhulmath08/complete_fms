---
id: 002-api-poultry-feeding-update-delete
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
status: complete
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 029-poultry-actions-api
implemented: true
---

# Story: 002-api-poultry-feeding-update-delete

## User Story

**As a** farm owner  
**I want** the API to update and delete poultry feeding rows  
**So that** clients can edit and remove feeding history after insert

## Acceptance Criteria

- [x] **Given** an active poultry group I own, **When** I PATCH a feeding, **Then** allowed fields update and the response returns the row
- [x] **Given** a feeding row I own, **When** I DELETE it, **Then** I get `204` and the row is hard-deleted
- [x] **Given** archived group or missing/cross-owner id, **When** I mutate, **Then** rejection matches module conventions
- [x] **Given** no bearer token, **When** I call PATCH/DELETE, **Then** I am unauthorized

## Technical Notes

- Mirror cow feeding mutation patterns (without requiring unit_cost unless already present)

## Out of Scope

- Soft-delete; UI
