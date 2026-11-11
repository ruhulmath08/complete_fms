---
id: 002-web-design-tokens
unit: 002-design-web
intent: 002-design-system-refresh
status: complete
priority: should
created: '2026-11-11T18:01:56Z'
assigned_bolt: 020-design-web
implemented: true
---

# Story: 002-web-design-tokens

## User Story

**As a** developer  
**I want** shared web design tokens for brand colors and shell pieces  
**So that** the refresh stays consistent and maintainable

## Acceptance Criteria

- [ ] **Given** the web app, **When** I inspect styling sources, **Then** menu green `#2f6a3a` and white-on-green menu text come from shared tokens/variables (not many unmanaged one-offs)
- [ ] **Given** signed-in routes, **When** they use the shell, **Then** they reuse shared sidebar/header/footer components
- [ ] **Given** tokens exist, **When** shell pages render, **Then** brand colors match FR-1 acceptance

## Technical Notes

- CSS variables or theme module under `web/src` shared UI
- Keep scope practical — do not build a full design-system package repo

## Dependencies

### Requires

- 001-web-app-shell

### Enables

- 004-web-milk-feeding-tables
- 005-web-tabular-lists

## Edge Cases

| Scenario           | Expected Behavior                                                                  |
| ------------------ | ---------------------------------------------------------------------------------- |
| Legacy page styles | Prefer migrating shell consumers; avoid breaking auth pages if still outside shell |

## Out of Scope

- Publishing an external npm design package
