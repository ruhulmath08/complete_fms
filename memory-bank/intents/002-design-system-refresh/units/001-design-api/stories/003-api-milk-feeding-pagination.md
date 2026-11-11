---
id: 003-api-milk-feeding-pagination
unit: 001-design-api
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 019-design-api
implemented: false
---

# Story: 003-api-milk-feeding-pagination

## User Story

**As a** farm owner  
**I want** milk and feeding history returned in pages of 10  
**So that** the web tables load quickly without downloading full history

## Acceptance Criteria

- [ ] **Given** a cow with more than 10 milk entries, **When** I request milk list with page size 10, **Then** I receive at most 10 items plus pagination `meta`
- [ ] **Given** I request the next page, **When** offset/page advances, **Then** I receive the next distinct set of entries
- [ ] **Given** feeding history, **When** I list feeding with page size 10, **Then** the same pagination contract applies
- [ ] **Given** empty history, **When** I list, **Then** I receive an empty `items` array and valid `meta` (not an error)

## Technical Notes

- Default/limit aligned to 10 for these list endpoints used by the refreshed tables
- Include fields needed for table totals (quantity, unit_price / price_per_unit) so clients can show total

## Dependencies

### Requires

- None (within this intent)

### Enables

- 004-web-milk-feeding-tables

## Edge Cases

| Scenario            | Expected Behavior                 |
| ------------------- | --------------------------------- |
| Invalid page/offset | 400 with clear error code         |
| limit > max allowed | Cap or reject per API conventions |

## Out of Scope

- Changing create milk/feeding business rules unrelated to listing
