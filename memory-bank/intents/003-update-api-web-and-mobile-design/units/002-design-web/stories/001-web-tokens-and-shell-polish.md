---
id: 001-web-tokens-and-shell-polish
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 025-design-web
implemented: true
---

# Story: 001-web-tokens-and-shell-polish

## User Story

**As a** farm owner
**I want** a polished, accessible signed-in shell with consistent tokens
**So that** navigation and chrome feel production ready on desktop and narrow screens

## Acceptance Criteria

- [ ] **Given** a signed-in session, **When** I use the shell, **Then** tokens drive color/typography/spacing for primary chrome
- [ ] **Given** viewport ≤800px with sidebar open, **When** I view the page, **Then** a scrim appears and content behind is not interactable
- [ ] **Given** the drawer or a header popover is open, **When** I press Escape, **Then** it closes and focus returns appropriately
- [ ] **Given** keyboard use, **When** I tab through chrome, **Then** `:focus-visible` styles are visible
- [ ] **Given** a signed-in page, **When** it loads, **Then** a skip link to main content is available

## Technical Notes

- Extend intent `002` AppShell; do not rebuild from scratch

## Dependencies

### Requires

- None

### Enables

- Later web table/layout stories

## Edge Cases

| Scenario              | Expected Behavior       |
| --------------------- | ----------------------- |
| Missing profile image | Fallback avatar remains |

## Out of Scope

- Real notification backend
