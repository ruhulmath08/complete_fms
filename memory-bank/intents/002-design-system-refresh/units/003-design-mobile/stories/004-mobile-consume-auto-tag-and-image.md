---
id: 004-mobile-consume-auto-tag-and-image
unit: 003-design-mobile
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 023-design-mobile
implemented: false
---

# Story: 004-mobile-consume-auto-tag-and-image

## User Story

**As a** farm owner  
**I want** mobile to use the API-generated tag and show the cow image  
**So that** web and mobile stay consistent after the refresh

## Acceptance Criteria

- [ ] **Given** I create a cow with name and breed, **When** create succeeds, **Then** the displayed tag matches the API-generated tag (I do not type a custom tag)
- [ ] **Given** a cow with an image, **When** I open detail (and list card if image is shown there), **Then** the image appears
- [ ] **Given** name/breed missing, **When** I try to create, **Then** validation prevents submit consistent with API rules

## Technical Notes

- Remove or lock manual tag input on create
- Mapper updates for image URL and generated tag fields

## Dependencies

### Requires

- 001-api-auto-tag-number
- 002-api-cow-image
- 003-mobile-cow-create-refresh

### Enables

- None

## Edge Cases

| Scenario                | Expected Behavior                  |
| ----------------------- | ---------------------------------- |
| Image URL fails to load | Placeholder; rest of detail usable |

## Out of Scope

- Changing tag generation algorithm on the client
