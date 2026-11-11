---
id: 003-mobile-cow-create-refresh
unit: 003-design-mobile
intent: 002-design-system-refresh
status: complete
priority: must
created: '2026-11-11T18:01:56Z'
assigned_bolt: 023-design-mobile
implemented: true
---

# Story: 003-mobile-cow-create-refresh

## User Story

**As a** farm owner  
**I want** the mobile add-cow flow to include a cow image and Weight (kg)  
**So that** mobile cow create matches the refreshed UX

## Acceptance Criteria

- [ ] **Given** I open add cow on mobile, **When** the form loads, **Then** I see a cow image control (pick/preview as platform allows)
- [ ] **Given** the weight field, **When** I view its label, **Then** it conveys **Weight (kg)** (EN) / localized equivalent including kg
- [ ] **Given** I submit a valid cow with optional image, **When** create succeeds, **Then** I land on detail/list consistently with existing navigation

## Technical Notes

- Wire image upload to API cow image contract when available
- Image optional unless later required

## Dependencies

### Requires

- 002-api-cow-image
- 001-mobile-list-cards

### Enables

- 004-mobile-consume-auto-tag-and-image

## Edge Cases

| Scenario                             | Expected Behavior                         |
| ------------------------------------ | ----------------------------------------- |
| Permission denied for gallery/camera | Clear message; allow create without image |

## Out of Scope

- Web add-cow page (separate story)
