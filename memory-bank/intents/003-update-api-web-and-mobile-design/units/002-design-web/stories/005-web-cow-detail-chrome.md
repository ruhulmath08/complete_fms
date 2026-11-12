---
id: 005-web-cow-detail-chrome
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 026-design-web
implemented: true
---

# Story: 005-web-cow-detail-chrome

## User Story

**As a** farm owner
**I want** cow detail with image on the left and info on the right, no Back links, and clearer Edit/Archive buttons
**So that** detail pages feel finished and navigation relies on the shell

## Acceptance Criteria

- [ ] **Given** a cow with an image, **When** I open detail, **Then** a rectangular image is on the left and info on the right (stack only on narrow viewports)
- [ ] **Given** no image, **When** I open detail, **Then** a rectangular placeholder occupies the image slot
- [ ] **Given** any detail/inner page (cows, poultry, crops, inventory, ledger, profile, settings), **When** loaded, **Then** no “← Back to …” link appears at the top
- [ ] **Given** Edit and Archive on detail toolbars, **When** viewed, **Then** they use shared production button styles with clear hierarchy
- [ ] **Given** Archive, **When** clicked, **Then** confirmation is still required before archiving

## Technical Notes

- Apply Back-link removal across domains, not only cows
- Image `alt` must be meaningful when content-bearing

## Dependencies

### Requires

- 001-web-tokens-and-shell-polish

### Enables

- Production detail chrome

## Edge Cases

| Scenario     | Expected Behavior                            |
| ------------ | -------------------------------------------- |
| Editing mode | Image/info layout remains coherent with form |

## Out of Scope

- Changing archive business rules
