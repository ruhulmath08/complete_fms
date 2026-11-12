---
id: 001-api-egg-update-delete
unit: 001-poultry-actions-api
intent: 004-poultry-history-actions-and-table-polish
status: complete
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 029-poultry-actions-api
implemented: true
---

# Story: 001-api-egg-update-delete

## User Story

**As a** farm owner  
**I want** the API to update and delete egg production rows  
**So that** web and mobile Action columns can maintain egg history after insert

## Acceptance Criteria

- [x] **Given** an active poultry group I own, **When** I PATCH an egg production, **Then** allowed fields update and the response returns the row
- [x] **Given** an egg row I own, **When** I DELETE it, **Then** I get `204` and the row is gone (hard-delete)
- [x] **Given** an archived group or missing/cross-owner id, **When** I mutate, **Then** the API rejects consistently with cows module conventions
- [x] **Given** no bearer token, **When** I call PATCH/DELETE, **Then** I am unauthorized

## Technical Notes

- Mirror cow milk PATCH/DELETE patterns in the poultry module

## Out of Scope

- Soft-delete; UI
