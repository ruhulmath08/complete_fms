---
id: 002-api-milk-feeding-update-delete
unit: 001-design-api
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 024-design-api
implemented: true
---

# Story: 002-api-milk-feeding-update-delete

## User Story

**As a** farm owner (via clients)
**I want** to update and delete milk and feeding rows through the API
**So that** table Action Edit/Delete can work after data is inserted

## Acceptance Criteria

- [ ] **Given** an existing milk entry owned by me, **When** I update allowed fields, **Then** the API persists changes and returns the updated resource
- [ ] **Given** an existing milk entry owned by me, **When** I delete it, **Then** it is removed (hard-delete default) and no longer listed
- [ ] **Given** an existing feeding entry owned by me, **When** I update or delete it, **Then** the same success behavior applies
- [ ] **Given** another owner's entry id, **When** I update/delete, **Then** the API rejects unauthorized access
- [ ] **Given** an archived cow's write rules, **When** update/delete is attempted, **Then** behavior matches existing write guards (document in technical design)

## Technical Notes

- Default: hard-delete for sub-records unless product owner later chooses soft-delete
- OpenAPI must document new endpoints

## Dependencies

### Requires

- 001-api-feeding-total-and-list-meta (preferred for total fields on update)

### Enables

- Web/mobile Action column (FR-13)

## Edge Cases

| Scenario                  | Expected Behavior           |
| ------------------------- | --------------------------- |
| Delete already-deleted id | 404                         |
| Partial update            | Only provided fields change |

## Out of Scope

- Update/delete for unrelated domains unless required by a table Action in the same intent construction spike
