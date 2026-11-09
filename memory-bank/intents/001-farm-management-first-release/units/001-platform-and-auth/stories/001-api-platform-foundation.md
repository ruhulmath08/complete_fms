---
id: 001-api-platform-foundation
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
status: draft
priority: must
created: 2026-11-09T06:55:29Z
assigned_bolt: 001-platform-and-auth
implemented: false
---

# Story: 001-api-platform-foundation

## User Story

**As a** farm owner / developer
**I want** a running FastAPI app with Postgres, Alembic, `/api/v1` routing, shared error format, and auth middleware hooks
**So that** web and mobile can rely on one consistent API baseline

## Acceptance Criteria

- [ ] Given local Postgres is available, When the API starts with migrations applied, Then health and OpenAPI are reachable under `/api/v1` conventions
- [ ] Given an unauthenticated private request, When it hits a protected stub/route, Then it returns unauthorized using `{code,message,details?}`
- [ ] Given list endpoints are introduced, When paging is used, Then offset/limit meta shape is available as a shared pattern

## Technical Notes

Establish project layout per standards; document upload path placeholder; no domain CRUD yet.

## Dependencies

### Requires
- Prior stories in this unit's API→web→mobile order as applicable; unit depends on `001-platform-and-auth` for domain units

### Enables
- Subsequent stories in this unit and client bolts for the same slice

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Unauthorized access | Reject with consistent API error |
| Validation failure | Stable `code` + user-facing `message` |

## Out of Scope

- Multi-farm / staff roles / advanced accounting / forecasting
