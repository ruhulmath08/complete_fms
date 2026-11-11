---
unit: 001-design-api
bolt: 019-design-api
stage: design
status: complete
updated: 2026-11-11T18:12:47Z
---

# Technical Design - Design API (Cows contract extensions)

## Architecture Pattern

Extend the existing **modular FastAPI monolith** `cows` feature module (Presentation → Application → Domain → Infrastructure). No new top-level module — this bolt evolves cows contracts for the design-system refresh.

**Rationale**: Same layout as bolt `004-cows` / platform auth; reuses JWT owner deps, error envelope, offset/limit paging, and local disk upload patterns from profile images.

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers + Pydantic schemas
├─────────────────────────────────────┤
│ Application                         │  Cow / milk / feeding services + TagNumberGenerator
├─────────────────────────────────────┤
│ Domain                              │  Tag format, image optional, list paging rules
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy, repositories, CowImageStore
└─────────────────────────────────────┘
```

### Backend touchpoints (this bolt)

```text
backend/app/modules/cows/
├── domain/           # tag generation rules; name/breed required on create
├── application/      # TagNumberGenerator; CowService create/update; list paging defaults
├── infrastructure/   # cows.image_path column; CowImageStore under uploads/
└── presentation/     # schemas (no client tag on create); image routes; OpenAPI

backend/uploads/
└── cow_images/       # gitignored; {owner_id}/{cow_id}/{filename}
```

Mount remains under `/api/v1`.

## Construction Decisions (resolves Open Questions)

| Decision | Choice | Notes |
|----------|--------|-------|
| Tag format | `name` + `breed` + 6 ASCII digits, **no separators** | Strip only leading/trailing whitespace from name/breed before concat; preserve internal spaces as typed |
| Tag on create | Server-generated only | `tag_number` **omitted** from create body (ignored if sent) |
| Tag after create | **Stable** | Updates to name/breed do **not** regenerate tag |
| Name/breed on create | **Required** non-empty strings | `422 VALIDATION_ERROR` if missing |
| Tag collision | Retry up to **10** times | Then `500 TAG_GENERATION_FAILED` (extremely unlikely at farm scale) |
| Tag uniqueness | Unchanged: unique among **active** cows per owner | Same partial unique index as `004-cows` |
| Cow image | **Optional** | JPEG/PNG/WebP; max **5 MB** (align with profile) |
| Image storage | `backend/uploads/cow_images/{owner_id}/{cow_id}/{filename}` | Outside Git; path stored on `cows.image_path` |
| Image URL | `image_url`: `/api/v1/cows/{cow_id}/image` when present else `null` | Authenticated stream; never expose raw filesystem path |
| Create with image | Prefer **multipart** create OR JSON create + `PUT/POST .../image` | Support both: JSON create without image; `PUT /cows/{id}/image` multipart field `image`; optional multipart create with same fields + `image` |
| Milk/feeding default `limit` | **10** | Was 20 in `004-cows`; max remains **100**; cows list default may stay 20 |
| Page meta | `{ total, limit, offset }` | Matches api-conventions |
| Milk `total` | **Client-computed** as `quantity × price_per_unit` | API does not add a `total` field in v1 of this bolt (additive later if needed) |
| ADR needed? | **No new ADR** unless implementation discovers conflict with existing upload/paging ADRs | Stage 3 skip expected |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Cows (changed behavior)

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows` | POST | Owner | **JSON** CowCreate **without** `tag_number`; `name`+`breed` required · **or** `multipart/form-data` same fields + optional `image` file | `201` Cow (includes generated `tag_number`, `image_url?`) |
| `/api/v1/cows` | GET | Owner | `limit`, `offset`, `include_archived?` | `{ items, meta }` (default limit may remain 20) |
| `/api/v1/cows/{cow_id}` | GET | Owner | — | Cow incl. `image_url` |
| `/api/v1/cows/{cow_id}` | PATCH | Owner | CowUpdate (no client tag invent; `tag_number` not writable) | Cow |
| `/api/v1/cows/{cow_id}/archive` | POST | Owner | — | Cow |
| `/api/v1/cows/{cow_id}/image` | PUT | Owner | `multipart` field `image` | Cow (updated `image_url`) |
| `/api/v1/cows/{cow_id}/image` | DELETE | Owner | — | Cow (`image_url` null) — optional but recommended |
| `/api/v1/cows/{cow_id}/image` | GET | Owner | — | Image bytes (`Content-Type` image/*); `404 COW_IMAGE_NOT_FOUND` if none |

### Milk (paging default change)

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows/{cow_id}/milk-productions` | POST | Owner | MilkCreate | `201` MilkProduction |
| `/api/v1/cows/{cow_id}/milk-productions` | GET | Owner | `limit` (default **10**), `offset` (default 0) | `{ items, meta }` newest first |

### Feeding (paging default change)

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/cows/{cow_id}/feedings` | POST | Owner | FeedingCreate | `201` CowFeeding |
| `/api/v1/cows/{cow_id}/feedings` | GET | Owner | `limit` (default **10**), `offset` (default 0) | `{ items, meta }` newest first |

### Schemas (field summary — deltas bold)

**CowCreate**: `name` (**required**), `breed` (**required**), `date_of_birth?`, `purpose`, `gender`, `color?`, `weight?`, `age?`, `acquired_by`, `purchase_date?`, `purchase_price?`, `notes?` — **no `tag_number`**

**Cow** (response): `id`, **`tag_number`** (generated), `name`, `breed`, …existing…, **`image_url`**, `is_archived`, timestamps

**MilkProduction / CowFeeding**: unchanged fields; list `meta.limit` defaults to 10

## Data Persistence

| Table | Change | Notes |
|-------|--------|-------|
| `cows` | Add nullable `image_path` TEXT | Relative path under upload root |
| `cows` | `name`, `breed` NOT NULL going forward for **new** rows | Migration: backfill empty string or placeholder for legacy nulls **or** keep nullable in DB but enforce NOT NULL only in application create — **prefer application enforce + migrate existing nulls to `''` only if needed**; recommend: DB columns stay nullable for legacy archived rows; create path requires non-empty |
| `milk_productions` / `cow_feedings` | No schema change | Paging is query-only |

### Migration

Alembic revision: add `cows.image_path` nullable; no change to tag uniqueness index.

## Security Design

| Concern | Approach |
|---------|----------|
| Authentication | Existing JWT `get_current_owner` |
| Authorization | All cow/image/list ops filtered by `owner_id`; foreign cow → `404 COW_NOT_FOUND` |
| Image access | GET image requires owner auth; no public static listing of upload dir |
| Uploads | content-type jpeg/png/webp; max 5 MB; store outside Git |
| Tag | Never trust client-supplied tag on create/update |

## NFR Implementation

| Requirement | Design Approach |
|-------------|-----------------|
| Performance | Indexed list by `(cow_id, produced_at/fed_at DESC)`; default page 10 |
| Compatibility | Additive fields (`image_url`); create contract change is **breaking for clients that sent tag_number** — coordinated in same intent’s web/mobile bolts |
| Contract-first | Update OpenAPI before web `021` / mobile `023` |

## Error Handling

| Error Type | HTTP | Code |
|------------|------|------|
| Validation (incl. missing name/breed) | 422 | `VALIDATION_ERROR` |
| Duplicate active tag (after retries exhausted / race) | 409 | `TAG_ALREADY_EXISTS` |
| Tag generation failed | 500 | `TAG_GENERATION_FAILED` |
| Invalid / oversized image | 422 | `INVALID_IMAGE` |
| Cow image missing | 404 | `COW_IMAGE_NOT_FOUND` |
| Cow archived (write) | 409 | `COW_ARCHIVED` |
| Not found / not owned | 404 | `COW_NOT_FOUND` |
| Unauthorized | 401 | `UNAUTHORIZED` |

Existing purchase/milk purpose errors unchanged.

## Application Use Cases

| Story | Use cases |
|-------|-----------|
| 001-api-auto-tag-number | `GenerateTagNumber`, `CreateCow` (no client tag) |
| 002-api-cow-image | `AttachCowImage`, `GetCowImage`, `ClearCowImage?`, Cow responses with `image_url` |
| 003-api-milk-feeding-pagination | `ListMilkProductions`, `ListCowFeedings` with default limit 10 |

## External Dependencies

| Service | Purpose | Integration |
|---------|---------|-------------|
| PostgreSQL | Persist cow `image_path` + existing rows | SQLAlchemy + Alembic |
| Local filesystem | Cow image bytes | `CowImageStore` (mirror `ProfileImageStore`) |
| Auth | Owner identity | `get_current_owner` |

## Testing Plan (preview for Stage 5)

- Unit: tag format (name+breed+6 digits); collision retry; name/breed required
- API: create without tag returns generated tag; reject empty name/breed; image upload/get/authz; milk/feeding default limit 10 and second page
- Owner isolation on image GET

## Out of Scope

- Web/mobile UI
- Notification APIs
- Regenerating tags on rename
- Returning computed milk `total` field (clients compute)
