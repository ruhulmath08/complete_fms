---
bolt: 010-crops
created: 2026-11-09T12:05:56Z
status: accepted
superseded_by: null
---

# ADR-007: Crop Name Uniqueness Among Active Catalog Entries Only

## Context

Crop cycles must pick a managed crop name from the owner’s catalog (FR-8), not free text. Soft archive (ADR-004 pattern applied to crop names) keeps retired catalog rows so historical cycles retain a stable `crop_name_id`. Standards do not say whether a display name may be reused after the previous catalog entry is archived. Forever-unique names block renaming/reuse of common labels (e.g. “Rice”); active-only uniqueness needs the same care as cow tags (ADR-006).

## Decision

1. Enforce **uniqueness of `name` per `owner_id` among active crop names only** (`is_archived = false`).
2. Implement with a **partial unique index** `(owner_id, name) WHERE is_archived = false` (Postgres; mirror with `sqlite_where` in tests).
3. On create/update of an active crop name, if another active name already matches (case-sensitive trim as stored) → `409 CROP_NAME_ALREADY_EXISTS`.
4. Archiving a crop name **does not clear** `name`; a new active catalog entry **may reuse** that name.
5. Stable identity for cycles and history is always **`crop_name_id`**, not the display string alone.
6. Creating or updating a cycle to select an **archived** crop name is rejected (`422 CROP_NAME_ARCHIVED`); existing cycles may keep referencing an archived name.

## Rationale

Catalog labels are working names, not permanent surrogate keys. Active-only uniqueness prevents two live picker options from colliding while allowing reuse after archive, matching ADR-006’s livestock-tag pattern for a different resource type. Documenting this as ADR-007 avoids implying ADR-006’s cow/tag wording applies verbatim to crops.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Cite ADR-006 only; no crops ADR | Less paperwork | Livestock-specific language; easy to mis-apply tag semantics | Prefer domain-specific ADR |
| Unique including archived | Simple unique constraint | Names never reusable | Poor fit for catalog reuse |
| Case-insensitive unique | Fewer near-duplicates | Locale folding complexity | Keep exact stored string uniqueness for v1 |
| No DB uniqueness; app-only check | Flexible | Race conditions | Prefer DB enforcement |

## Consequences

### Positive

- Clear active-catalog invariant; enforceable in Postgres
- Name reuse after archive without losing historical cycle FK
- Cycles always key by `crop_name_id`

### Negative

- Display name alone is ambiguous across time
- If unarchive is added later, restore fails when another active name holds the label

### Risks

- Owners confuse two catalog rows that once shared a label — mitigate by showing archived badge and preferring `crop_name_id` in APIs

## Related

- **Stories**: 001-api-crop-names-and-cycles
- **Standards**: none yet; catalog identity note candidate later
- **Previous ADRs**: ADR-004 (soft archive), ADR-006 (active-only uniqueness pattern for cows)
