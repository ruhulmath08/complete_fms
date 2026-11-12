---
id: 002-mobile-history-no-and-action-colors
unit: 003-poultry-actions-mobile
intent: 004-poultry-history-actions-and-table-polish
status: complete
priority: must
created: "2026-11-12T09:47:02Z"
assigned_bolt: 031-poultry-actions-mobile
implemented: true
---

# Story: 002-mobile-history-no-and-action-colors

## User Story

**As a** farm owner  
**I want** mobile history rows to use **No.** labeling and primary/danger Edit/Delete colors  
**So that** mobile matches the polished web table chrome

## Acceptance Criteria

- [x] **Given** history UIs that show a row index, **When** labeled, **Then** they use **No.** / `rowNumber` (BN equivalent)—not `#`
- [x] **Given** Edit/Delete actions on poultry (and cow histories if shown with icons), **When** rendered, **Then** Edit uses primary color and Delete uses danger/red
- [x] **Given** EN and BN, **When** viewing labels, **Then** localized strings appear

## Technical Notes

- Reuse `AppTokens` primary/danger; ensure `rowNumber` l10n where needed

## Out of Scope

- Web CSS
