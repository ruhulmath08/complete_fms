---
bolt: 001-platform-and-auth
created: 2026-11-09T09:25:51Z
status: accepted
superseded_by: null
---

# ADR-002: Use Sync SQLAlchemy 2.x for v1

## Context

The data stack mandates SQLAlchemy 2.x + Alembic + local PostgreSQL, but does not specify sync vs async engines. Every later domain module will follow the session/dependency pattern established in the platform bolt. v1 targets a single owner, local-first development, and simple ops without Docker.

## Decision

Use **synchronous SQLAlchemy 2.x** with a FastAPI dependency-injected `Session` for v1 persistence. Defer async SQLAlchemy/asyncpg unless a measured need appears.

## Rationale

Sync sessions keep the first bolt and subsequent modules simpler (fewer async pitfalls in tests, Alembic, and tutorials). Single-owner traffic does not justify async IO complexity yet. The domain/application layers stay free of ORM details behind repository ports, so an async migration remains possible later.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Async SQLAlchemy + asyncpg | Better concurrency under load | Higher complexity for v1 local single-owner app; harder pytest/Alembic ergonomics | Premature for v1 scope |
| Raw SQL / another ORM | Different trade-offs | Conflicts with data-stack standard | Out of bounds |

## Consequences

### Positive

- Faster Construction for platform and domain modules
- Simpler test setup with sync sessions

### Negative

- Blocking DB calls under the event loop if concurrency grows later

### Risks

- Future high-concurrency hosting may need async — mitigate by keeping repositories behind interfaces and documenting this ADR as the v1 constraint

## Related

- **Stories**: 001-api-platform-foundation (and all API stories using Postgres)
- **Standards**: data-stack.md
- **Previous ADRs**: none
