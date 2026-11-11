---
id: 005-web-tabular-lists
unit: 002-design-web
intent: 002-design-system-refresh
status: draft
priority: should
created: 2026-11-11T18:01:56Z
assigned_bolt: 021-design-web
implemented: false
---

# Story: 005-web-tabular-lists

## User Story

**As a** farm owner  
**I want** other tabular web lists presented as tables  
**So that** scanning records feels consistent with milk/feeding

## Acceptance Criteria

- [ ] **Given** a primary web list that is naturally columnar (e.g. cows list and similar domain lists in scope of the refresh), **When** I view it, **Then** it uses a table layout rather than an ad-hoc dense non-table list
- [ ] **Given** a narrow viewport, **When** columns overflow, **Then** horizontal scroll or an equivalent usable pattern keeps data accessible
- [ ] **Given** table styling, **When** compared to milk/feeding tables, **Then** visual treatment is aligned via shared tokens/components where practical

## Technical Notes

- Prefer updating existing list pages under the shell; do not invent new domains
- Priority Should — must-haves (shell, cow form, milk/feeding) come first in the same bolt if time-boxed

## Dependencies

### Requires

- 001-web-app-shell
- 002-web-design-tokens

### Enables

- None

## Edge Cases

| Scenario              | Expected Behavior            |
| --------------------- | ---------------------------- |
| Very wide column sets | Horizontal scroll acceptable |

## Out of Scope

- Redesigning every settings form as a table
