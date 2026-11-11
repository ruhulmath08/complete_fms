---
id: 001-api-auto-tag-number
unit: 001-design-api
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 019-design-api
implemented: false
---

# Story: 001-api-auto-tag-number

## User Story

**As a** farm owner  
**I want** the system to generate a cow tag number from name, breed, and random digits  
**So that** I do not invent tags manually and tags stay unique

## Acceptance Criteria

- [ ] **Given** valid name and breed on cow create, **When** I create a cow without supplying a custom tag, **Then** `tag_number` equals name + breed + exactly 6 digits
- [ ] **Given** a generated tag that already exists for my farm/owner, **When** create runs, **Then** the API retries or rejects until a unique tag is stored
- [ ] **Given** name or breed missing, **When** I submit create, **Then** the API rejects with a clear validation error (tag cannot be generated)
- [ ] **Given** a created cow, **When** I fetch it, **Then** the same generated `tag_number` is returned to web and mobile

## Technical Notes

- Prefer server-side generation as source of truth
- Document whether separators are used (default: none, per requirements assumptions)

## Dependencies

### Requires

- None (within this intent)

### Enables

- 003-web-add-cow-image-and-labels
- 004-mobile-consume-auto-tag-and-image

## Edge Cases

| Scenario             | Expected Behavior                                         |
| -------------------- | --------------------------------------------------------- |
| Very long name+breed | Enforce max length / truncate policy documented in design |
| Unicode name/breed   | Allowed if stored safely; digits still ASCII 0-9          |

## Out of Scope

- Changing tag on every edit by default
- Client-only tag generation without API agreement
