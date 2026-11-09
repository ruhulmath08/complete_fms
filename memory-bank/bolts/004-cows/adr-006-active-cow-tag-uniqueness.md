---
bolt: 004-cows
created: 2026-11-09T10:29:56Z
status: accepted
superseded_by: null
---

# ADR-006: Tag Uniqueness Among Active Cows Only

## Context

Each cow requires a `tag_number` for day-to-day farm identification. Soft archive (ADR-004) keeps retired cows in the database with their historical tag. Standards do not say whether a tag may be reused after the previous holder is archived. Forever-unique tags block common reuse of physical ear tags; active-only uniqueness needs careful history and future unarchive semantics.

## Decision

1. Enforce **uniqueness of `tag_number` per `owner_id` among active cows only** (`is_archived = false`).
2. Implement with a **partial unique index** `(owner_id, tag_number) WHERE is_archived = false` (Postgres).
3. On create/update of an active cow, if another active cow already has that tag → `409 TAG_ALREADY_EXISTS`.
4. Archiving a cow **does not clear** `tag_number`; a new active cow **may reuse** that tag.
5. Stable identity for history and milk/feeding is always **`cow_id`**, not tag text alone.

## Rationale

Physical tags are often reused when an animal leaves the active herd. Active-only uniqueness matches that practice while still preventing two live cows from sharing a tag. Partial unique indexes express the rule in the database. Reports and APIs that need a specific animal must use `cow_id`; tag is a current working label, not a permanent surrogate key.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Unique including archived | Simple unique constraint; no tag ambiguity in history keyed only by tag | Tags never reusable; poor fit for ear-tag reuse | Rejected after product preference for reuse |
| No DB uniqueness; app-only check | Flexible | Race conditions; weaker integrity | Prefer DB enforcement |
| Clear tag on archive | Avoids historical duplicate tags | Loses label on archived record; odd for GET archived | Keep historical tag on the row |

## Consequences

### Positive

- Tag reuse after archive matches farm practice
- Clear active-herd invariant; enforceable in Postgres

### Negative

- Tag string alone is ambiguous across time (multiple cows may have held “A-12”)
- If unarchive is added later, restore fails when another active cow holds the tag

### Risks

- Owners search history by tag and see multiple cows — mitigate by preferring `cow_id` in APIs and showing tag + dates/name in clients

## Related

- **Stories**: 001-api-cow-records
- **Standards**: none yet; livestock identity note candidate later
- **Previous ADRs**: ADR-004 (soft archive)
