---
bolt: 004-cows
created: 2026-11-09T10:23:23Z
status: accepted
superseded_by: null
---

# ADR-004: Soft-Archive Livestock with Write Block (No Unarchive in v1)

## Context

Standards require owner-scoped domain modules and soft business rules for livestock, but do not define how a cow leaves the “active” herd. Hard delete would erase history that milk and feeding records depend on. Clients need a stable identity for past production while default lists show only working animals. Later modules (poultry, etc.) will face the same retirement question.

## Decision

1. Retire cows with **`is_archived=true`** (soft archive). No hard delete in v1.
2. Default list endpoints return **active** cows only; `GET` by id may return archived cows.
3. **Reject writes** on archived cows (update profile, add milk, add feeding) with `409 COW_ARCHIVED`.
4. **No unarchive** API in v1. Re-activating an archived cow is out of scope until a later intentional change.

## Rationale

Soft archive preserves history and tag/identity for reporting while keeping active herd UX simple. Blocking writes avoids mutating retired animals by mistake. Omitting unarchive keeps v1 small and avoids half-baked restore semantics (tag conflicts, purpose changes, etc.).

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Hard delete | Simple storage | Loses history; breaks milk/feeding FKs or forces cascade | History is required for farm records |
| Soft archive + unarchive in v1 | Flexible | Tag reuse / restore rules complicate first release | Defer until needed |
| Hide only in UI; allow API writes | Less server logic | Clients diverge; accidental writes on retired cows | Server must enforce |

## Consequences

### Positive

- Clear active vs retired model reusable by later livestock modules
- History remains readable; contracts stay simple for web/mobile

### Negative

- Mistaken archives cannot be undone without a future feature or DB intervention
- Archived rows accumulate; lists must filter by `is_archived`

### Risks

- Operators archive by mistake — mitigate with clear UI confirmation in client bolts; consider unarchive ADR later if needed

## Related

- **Stories**: 001-api-cow-records, 002-api-cow-milk-and-feeding
- **Standards**: system-architecture.md (domain modules); candidate for livestock lifecycle note later
- **Previous ADRs**: ADR-002 (persistence stack)
