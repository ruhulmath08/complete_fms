---
id: 002-api-cow-image
unit: 001-design-api
intent: 002-design-system-refresh
status: complete
priority: must
created: '2026-11-11T18:01:56Z'
assigned_bolt: 019-design-api
implemented: true
---

# Story: 002-api-cow-image

## User Story

**As a** farm owner  
**I want** to attach an image to a cow  
**So that** the add-cow and detail UIs can show the animal

## Acceptance Criteria

- [ ] **Given** I am authenticated, **When** I create or update a cow with an image upload, **Then** the image is stored under the documented local upload path outside Git and linked to the cow
- [ ] **Given** a cow with an image, **When** I fetch the cow, **Then** the response includes a usable image URL/path for clients
- [ ] **Given** an unauthenticated request for a private cow image, **When** access is attempted, **Then** access is denied
- [ ] **Given** create without an image, **When** I create a cow, **Then** create still succeeds (image optional unless product owner later requires it)

## Technical Notes

- Reuse profile-image storage patterns where practical
- Document multipart field name and URL shape in OpenAPI

## Dependencies

### Requires

- None (within this intent)

### Enables

- 003-web-add-cow-image-and-labels
- 003-mobile-cow-create-refresh
- 004-mobile-consume-auto-tag-and-image

## Edge Cases

| Scenario              | Expected Behavior                      |
| --------------------- | -------------------------------------- |
| Unsupported file type | Validation error                       |
| Oversized file        | Validation error with limit documented |

## Out of Scope

- Cloud object storage migration
- Image CDN
