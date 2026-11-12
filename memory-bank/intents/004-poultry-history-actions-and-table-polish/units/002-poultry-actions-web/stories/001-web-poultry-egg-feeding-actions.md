---
id: 001-web-poultry-egg-feeding-actions
unit: 002-poultry-actions-web
intent: 004-poultry-history-actions-and-table-polish
status: draft
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 030-poultry-actions-web
implemented: false
---

# Story: 001-web-poultry-egg-feeding-actions

## User Story

**As a** farm owner  
**I want** Edit and Delete actions on poultry Egg production and Feeding tables  
**So that** I can maintain those histories on the web after inserting data

## Acceptance Criteria

- [ ] **Given** egg rows on poultry detail, **When** I view the table, **Then** an **Action** column shows Edit and Delete
- [ ] **Given** Edit, **When** I save, **Then** the row updates via PATCH and the table refreshes
- [ ] **Given** Delete, **When** I confirm, **Then** the row is removed via DELETE and the table refreshes; Cancel leaves it
- [ ] **Given** Feeding table, **When** rows exist, **Then** the same Action behavior applies
- [ ] **Given** archived group / eggs not eligible, **When** viewing, **Then** actions are hidden or disabled
- [ ] **Given** add forms, **When** I add egg or feeding, **Then** create still works (FR-8)

## Technical Notes

- Depends on bolt `029` APIs; reuse cow detail Action UX

## Out of Scope

- Mobile
