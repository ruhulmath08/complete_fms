---
id: 003-web-add-cow-image-and-labels
unit: 002-design-web
intent: 002-design-system-refresh
status: complete
priority: must
created: '2026-11-11T18:01:56Z'
assigned_bolt: 021-design-web
implemented: true
---

# Story: 003-web-add-cow-image-and-labels

## User Story

**As a** farm owner  
**I want** the add-cow page to show a cow image, Weight (kg), and an auto-generated tag  
**So that** creating a cow matches the refreshed design and rules

## Acceptance Criteria

- [ ] **Given** I open the add-cow page, **When** the form loads, **Then** I see a cow image control (preview + choose/upload)
- [ ] **Given** the weight field, **When** I view its label, **Then** it reads **Weight (kg)**
- [ ] **Given** I provide name and breed (and other required fields), **When** I create a cow, **Then** I do not manually invent a tag; the UI uses/displays the API-generated tag
- [ ] **Given** create succeeds with an image, **When** I view the cow, **Then** the image is shown

## Technical Notes

- Depends on `001-design-api` tag + image contracts
- Tag field read-only or omitted on create

## Dependencies

### Requires

- 001-api-auto-tag-number
- 002-api-cow-image
- 001-web-app-shell

### Enables

- None

## Edge Cases

| Scenario           | Expected Behavior                                                          |
| ------------------ | -------------------------------------------------------------------------- |
| Image upload fails | Clear error; cow create policy documented (fail all vs save without image) |
| Missing name/breed | Client validation before submit                                            |

## Out of Scope

- Changing unrelated cow business fields beyond labels/image/tag UX
