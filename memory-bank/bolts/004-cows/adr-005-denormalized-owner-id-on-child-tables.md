---
bolt: 004-cows
created: 2026-11-09T10:23:23Z
status: accepted
superseded_by: null
---

# ADR-005: Denormalize owner_id on Child Event Tables

## Context

Every private route must authorize to the signed-in owner only. Milk productions and cow feedings are children of a cow but are listed and written under owner auth. Looking up ownership only via `JOIN cows` on every child query works, but every later production-style module (poultry logs, crop events, inventory movements) will repeat the same pattern. Standards do not prescribe how owner scope is stored on child rows.

## Decision

Store **`owner_id` (FK → owners)** on child tables such as `milk_productions` and `cow_feedings`, set from the authenticated owner at write time, and **filter every child query by `owner_id`** (in addition to `cow_id` where applicable). Cow ownership remains authoritative for “does this cow belong to me?”; child `owner_id` must match the parent cow’s owner and must not be client-supplied as a trust boundary.

## Rationale

Denormalized `owner_id` makes owner isolation index-friendly and keeps repository methods consistent with the cow table (`WHERE owner_id = :current`). It avoids subtle leaks if a join is omitted. Parent cow checks still enforce aggregate rules (purpose, archive); child `owner_id` is a copy for scoping and defense in depth, not a second source of truth for farm identity.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Scope only via JOIN to `cows` | Normalized | Easy to forget join; heavier list queries | Weaker default isolation pattern |
| No owner on children; trust cow_id alone | Less columns | Cross-owner cow_id guessing needs join every time | Prefer explicit owner filter |
| Client-sent owner_id | N/A | Trivial privilege escalation | Forbidden |

## Consequences

### Positive

- Uniform owner-scoped repositories across domain modules
- Simpler indexes and isolation tests (`owner_id` + time)

### Negative

- Redundant column; must stay in sync with parent cow’s owner (immutable owner in v1 reduces drift risk)

### Risks

- Future owner transfer / multi-farm would require backfill — out of v1 scope; document if that changes

## Related

- **Stories**: 002-api-cow-milk-and-feeding (and cow records ownership)
- **Standards**: system-architecture.md (owner-only routes); candidate persistence note later
- **Previous ADRs**: ADR-002
