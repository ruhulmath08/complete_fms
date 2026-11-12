---
id: 002-web-history-no-and-action-colors
unit: 002-poultry-actions-web
intent: 004-poultry-history-actions-and-table-polish
status: draft
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 030-poultry-actions-web
implemented: false
---

# Story: 002-web-history-no-and-action-colors

## User Story

**As a** farm owner  
**I want** history tables to show **No.** instead of `#` and clear primary/danger Action colors  
**So that** tables look consistent and Edit/Delete are visually distinct

## Acceptance Criteria

- [ ] **Given** any web history table with a row index column, **When** rendered, **Then** the header is **No.** (not `#`)
- [ ] **Given** poultry and cow history Action icons, **When** shown, **Then** Edit uses primary styling and Delete uses danger/red
- [ ] **Given** crop expense/harvest (and other `#` history tables), **When** updated, **Then** they also use **No.**

## Technical Notes

- Align cow milk/feeding headers to **No.** if still `No` without period
- CSS: primary edit vs `btn-icon-danger` for delete

## Out of Scope

- Mobile-specific Material theming (mobile unit)
