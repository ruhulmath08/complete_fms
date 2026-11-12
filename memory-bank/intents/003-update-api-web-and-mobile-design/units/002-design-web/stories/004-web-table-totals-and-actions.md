---
id: 004-web-table-totals-and-actions
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 026-design-web
implemented: false
---

# Story: 004-web-table-totals-and-actions

## User Story

**As a** farm owner
**I want** Total columns where meaningful and Edit/Delete actions on every data table
**So that** I can understand amounts and maintain rows after inserting data

## Acceptance Criteria

- [ ] **Given** the cow Feeding table, **When** rows are shown, **Then** a **Total** column appears per row
- [ ] **Given** Milk production, **When** rows are shown, **Then** **Total** remains
- [ ] **Given** other tables with meaningful totals, **When** shown, **Then** Total is included; otherwise omitted
- [ ] **Given** a data table with rows, **When** rendered, **Then** an **Action** column shows Edit and Delete icons with accessible names
- [ ] **Given** Edit, **When** used, **Then** I can update the row via API and the table refreshes
- [ ] **Given** Delete, **When** confirmed, **Then** the row is removed and the table refreshes
- [ ] **Given** an archived/read-only cow, **When** viewing tables, **Then** actions are disabled or hidden consistently

## Technical Notes

- Requires API stories 001 and 002
- Apply across application data tables in scope, starting with milk/feeding then entity/history tables

## Dependencies

### Requires

- 001-api-feeding-total-and-list-meta
- 002-api-milk-feeding-update-delete
- 002-web-universal-paginated-tables

### Enables

- Production table UX complete

## Edge Cases

| Scenario              | Expected Behavior              |
| --------------------- | ------------------------------ |
| Cancel delete confirm | No change                      |
| Edit validation error | Show field/API error; keep row |

## Out of Scope

- Soft-delete unless product owner changes default
