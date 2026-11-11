---
id: 004-web-milk-feeding-tables
unit: 002-design-web
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 021-design-web
implemented: false
---

# Story: 004-web-milk-feeding-tables

## User Story

**As a** farm owner  
**I want** milk and feeding history as paginated tables on web  
**So that** I can scan production and feeding records clearly

## Acceptance Criteria

- [ ] **Given** a milk-purpose cow with milk entries, **When** I view milk history on web, **Then** I see a Bootstrap table with columns including No, date+time, unit price, total, and note (quantity/unit included if needed for total)
- [ ] **Given** more than 10 milk entries, **Wh˝en** the table loads, **Then** it shows 10 rows and pagination controls to reach other pages
- [ ] **Given** feeding entries for a cow, **When** I view feeding history on web, **Then** I see a table with the same page size (10) and pagination pattern, columns covering date+time, feed type/name, quantity, unit, and note at minimum
- [ ] **Given** empty history, **When** I open the table, **Then** I see a clear empty state (not a broken table)
- [ ] **Given** an API error, **When** the list fails, **Then** I see a clear error state

## Technical Notes

- Assume total = quantity × unit price unless product owner specifies otherwise
- Use API pagination from 003-api-milk-feeding-pagination

## Dependencies

### Requires

- 003-api-milk-feeding-pagination
- 001-web-app-shell

### Enables

- 005-web-tabular-lists

## Edge Cases

| Scenario           | Expected Behavior                                           |
| ------------------ | ----------------------------------------------------------- |
| Meat-only cow      | Milk table not required / not shown per first-release rules |
| Missing unit price | Total/empty cell behavior documented                        |

## Out of Scope

- Mobile table layouts (mobile uses cards/lists)
