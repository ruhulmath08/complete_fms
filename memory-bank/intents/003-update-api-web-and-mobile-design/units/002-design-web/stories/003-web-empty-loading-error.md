---
id: 003-web-empty-loading-error
unit: 002-design-web
intent: 003-update-api-web-and-mobile-design
status: draft
priority: must
created: "2026-11-12T07:34:21Z"
assigned_bolt: 025-design-web
implemented: false
---

# Story: 003-web-empty-loading-error

## User Story

**As a** farm owner
**I want** clear empty, loading, and error states on lists and details
**So that** I always know what is happening and what to do next

## Acceptance Criteria

- [ ] **Given** a loading list/detail, **When** data is fetching, **Then** a shared loading primitive is shown (not only a muted one-off `<p>`)
- [ ] **Given** an empty list with an Add action, **When** I view it, **Then** empty state message + optional primary CTA appear
- [ ] **Given** a failed request, **When** the error is shown, **Then** shared error UI announces accessibly (`role="alert"` or equivalent)
- [ ] **Given** primary entity list screens, **When** reviewed, **Then** they use the shared primitives

## Technical Notes

- May extend existing `ErrorBanner`

## Dependencies

### Requires

- None (can land with layout)

### Enables

- Consistent table pages

## Edge Cases

| Scenario                 | Expected Behavior           |
| ------------------------ | --------------------------- |
| Error then retry success | Error clears; table renders |

## Out of Scope

- Mobile widgets (mobile unit)
