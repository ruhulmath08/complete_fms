---
id: 001-mobile-poultry-egg-feeding-actions
unit: 003-poultry-actions-mobile
intent: 004-poultry-history-actions-and-table-polish
status: complete
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 031-poultry-actions-mobile
implemented: true
---

# Story: 001-mobile-poultry-egg-feeding-actions

## User Story

**As a** farm owner  
**I want** to edit and delete egg and feeding entries on mobile  
**So that** I can maintain poultry history without a design or API blocker

## Acceptance Criteria

- [x] **Given** egg entries on poultry detail, **When** I use Edit, **Then** I can change fields and save via PATCH
- [x] **Given** Delete on an egg entry, **When** I confirm, **Then** the row is removed; Cancel keeps it
- [x] **Given** feeding entries, **When** I Edit/Delete, **Then** the same behavior applies via feeding APIs
- [x] **Given** archived / non-eligible group, **When** viewing, **Then** mutations are disabled or hidden
- [x] **Given** add forms, **When** I add egg or feeding, **Then** create still works
- [x] **Given** new strings, **When** locale is EN or BN, **Then** labels resolve

## Technical Notes

- Wire domain/API/DI for update/delete; mirror cow mobile Action patterns

## Out of Scope

- Web UI
