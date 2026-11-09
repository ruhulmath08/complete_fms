---
unit: 001-platform-and-auth
bolt: 001-platform-and-auth
stage: design
status: complete
updated: 2026-11-09T09:16:30Z
---

# Technical Design - Platform and Auth (API)

## Architecture Pattern

**Modular monolith with layered feature package (Presentation → Application → Domain → Infrastructure)** inside `backend/`.

**Rationale**:
- Matches `system-architecture` (modular FastAPI monolith, feature modules)
- Keeps business rules in the API for shared web/mobile clients
- Aligns with DDD domain model from Stage 1 without requiring microservices
- Auth module establishes shared platform primitives used by later domain modules

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  FastAPI routers, deps, schemas (Pydantic)
├─────────────────────────────────────┤
│ Application                         │  Use cases / services orchestration
├─────────────────────────────────────┤
│ Domain                              │  Entities, VOs, rules, repo interfaces
├─────────────────────────────────────┤
│ Infrastructure                      │  SQLAlchemy, JWT, Argon2, disk uploads
└─────────────────────────────────────┘
```

### Proposed backend layout (this bolt)

```text
backend/
├── app/
│   ├── main.py                 # FastAPI app factory
│   ├── core/                   # settings, logging, security helpers
│   │   ├── config.py
│   │   ├── security.py         # JWT + password hashing facades
│   │   └── errors.py           # ApiError models + exception handlers
│   ├── db/                     # engine, session, base, alembic hook
│   ├── api/
│   │   └── v1/
│   │       ├── router.py       # mounts feature routers under /api/v1
│   │       ├── deps.py         # get_db, get_current_owner
│   │       ├── health.py
│   │       └── schemas_common.py  # PageMeta, ApiError response
│   └── modules/
│       └── auth/               # Platform + Auth feature
│           ├── domain/
│           ├── application/
│           ├── infrastructure/
│           └── presentation/   # routers: auth, profile, settings, config
├── alembic/
├── tests/
├── uploads/                    # gitignored local disk root
│   └── profile_images/
├── .env.example
├── pyproject.toml / requirements.txt
└── README.md                   # run/migrate notes
```

## Construction Decisions (resolves Open Questions)

| Decision | Choice | Notes |
|----------|--------|-------|
| Upload directory | `backend/uploads/profile_images/` | Outside Git (gitignore `backend/uploads/`); serve via authenticated/static route later or return relative URL path; swap to object storage at deploy |
| Access token TTL | **15 minutes** | Short-lived JWT access |
| Refresh token TTL | **7 days** | Rotated on each refresh; reuse detection on replay |
| Password hashing | **Argon2id** via `pwdlib` or `argon2-cffi` | Prefer Argon2 over bcrypt per modern guidance; never log hashes in debug dumps with secrets |
| Pagination default | `limit=20`, `offset=0`, max `limit=100` | Matches api-conventions example shape |
| Suggested units | Static list: `kg`, `g`, `L`, `ml`, `pcs`, `bag`, `dozen` | Exposed as read-only config endpoint; free-text still allowed on quantity fields in later modules |
| JWT library | PyJWT (or `python-jose` only if already preferred; prefer PyJWT) | HS256 with secret from env for local v1 |
| ORM | SQLAlchemy 2.x + Alembic | Per data-stack |

## API Design

Base path: `/api/v1`  
Auth header: `Authorization: Bearer <access_token>`  
JSON fields: `snake_case`  
Errors: `{ "code", "message", "details?" }`

### Platform

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/health` | GET | Public | — | `{ "status": "ok" }` |
| `/api/v1/config/suggested-units` | GET | Public or Owner | — | `{ "items": ["kg", "g", "L", "ml", "pcs", "bag", "dozen"] }` |
| OpenAPI | GET | Public | — | FastAPI `/openapi.json` / `/docs` (root or documented) |

### Auth

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/auth/signup` | POST | Public | `multipart/form-data`: profile_image file + fields `full_name`, `email`, `phone`, `address`, `latitude`, `longitude`, `password`, `confirm_password` | `201` OwnerProfile (no tokens required on signup; optional: auto sign-in — **design choice: return profile only; client signs in**) |
| `/api/v1/auth/signin` | POST | Public | `{ email, password }` | `{ access_token, refresh_token, token_type: "bearer", expires_in }` |
| `/api/v1/auth/refresh` | POST | Public (refresh body) | `{ refresh_token }` | Same token response shape; rotates refresh |
| `/api/v1/auth/signout` | POST | Owner (access) | Optional `{ refresh_token }` to revoke specific; if omitted revoke all active for owner | `204` |

### Profile & settings

| Endpoint | Method | Auth | Request | Response |
|----------|--------|------|---------|----------|
| `/api/v1/me` | GET | Owner | — | OwnerProfile |
| `/api/v1/me` | PATCH | Owner | multipart or JSON+optional image: updatable profile fields | OwnerProfile |
| `/api/v1/farm-settings` | GET | Owner | — | `{ currency_code, ... }` |
| `/api/v1/farm-settings` | PATCH | Owner | `{ currency_code }` | FarmSettings |

### Response shapes

**OwnerProfile** (never includes password_hash or tokens):

```json
{
  "id": "uuid",
  "full_name": "string",
  "email": "string",
  "phone": "string",
  "address": "string",
  "latitude": 0.0,
  "longitude": 0.0,
  "profile_image_url": "/api/v1/me/profile-image",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601"
}
```

**TokenResponse**:

```json
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Paged list pattern** (shared helper for later modules):

```json
{
  "items": [],
  "meta": { "total": 0, "limit": 20, "offset": 0 }
}
```

### Profile image serving

| Endpoint | Method | Auth | Notes |
|----------|--------|------|-------|
| `/api/v1/me/profile-image` | GET | Owner | Streams current owner's image from disk; avoids exposing raw filesystem paths to clients |

## Data Persistence

| Table | Columns | Relationships / indexes |
|-------|---------|-------------------------|
| `owners` | `id` UUID PK, `full_name` TEXT NOT NULL, `email` CITEXT/unique lower, `phone` TEXT UNIQUE, `address` TEXT, `latitude` DOUBLE, `longitude` DOUBLE, `profile_image_path` TEXT, `password_hash` TEXT, `created_at`, `updated_at` | Unique email (case-insensitive), unique phone |
| `farm_settings` | `id` UUID PK, `owner_id` UUID UNIQUE FK → owners, `currency_code` TEXT NOT NULL DEFAULT `'BDT'`, `created_at`, `updated_at` | 1:1 with owner |
| `refresh_tokens` | `id` UUID PK, `owner_id` UUID FK → owners, `token_hash` TEXT UNIQUE, `expires_at`, `revoked_at` NULL, `replaced_by_token_id` UUID NULL FK, `family_id` UUID, `created_at`, `last_used_at` NULL | Index `(owner_id, revoked_at)`; lookup by `token_hash`; `family_id` groups rotation chain for reuse wipe |

### Migration plan

1. Alembic initial revision: create `owners`, `farm_settings`, `refresh_tokens`
2. App startup docs: `alembic upgrade head` before serving
3. No seed owner required — signup creates first owner

### Persistence mapping notes

- Store **hash of refresh JWT** (or opaque refresh if we use opaque tokens — **decision: JWT refresh with server-side hash of raw token string** for revocation/rotation)
- Email uniqueness: store normalized lowercase email; compare case-insensitively
- Profile path: relative path under `uploads/profile_images/{owner_id}/{filename}`

## Security Design

| Concern | Approach |
|---------|----------|
| Authentication | Email/password → Argon2id hash verify → issue HS256 JWT access (15m) + refresh (7d) |
| Refresh rotation | On refresh: validate token, ensure DB row active, issue new pair, mark old revoked + `replaced_by`, set `last_used_at` |
| Reuse detection | If presented refresh matches a **revoked** row that was replaced → revoke **all** tokens in `family_id` for that owner; return `401` |
| Authorization | `get_current_owner` dependency on private routes; owner-only (no RBAC) |
| Password rules | ≥8 chars, ≥1 letter, ≥1 number; confirm match on signup only |
| Uploads | Validate content-type (image/jpeg, image/png, image/webp); max size e.g. 5 MB; store outside Git |
| Secrets | `SECRET_KEY`, `DATABASE_URL`, upload root via env; never log passwords/tokens |
| CORS | Configurable origins for local Vite + Flutter dev |
| HTTPS | Deferred to hosting/Operations |

## NFR Implementation

| Requirement | Design Approach |
|-------------|-----------------|
| Performance | Single-owner v1; indexed email/phone/token_hash lookups; no Redis |
| Scalability | Modular monolith ready for later module adds; not horizontally scaled in v1 |
| Reliability | Postgres + Alembic; durable across API restarts |
| Observability | stdlib logging: auth success/failure without secrets; unhandled errors |
| Contract-first clients | OpenAPI from FastAPI; this design is the pre-client contract for web/mobile bolts |

## Error Handling

| Error Type | HTTP | Code | Message (example) |
|------------|------|------|-------------------|
| Validation | 422 | `VALIDATION_ERROR` | Field-level details in `details` |
| Duplicate email | 409 | `EMAIL_ALREADY_EXISTS` | Email is already registered. |
| Duplicate phone | 409 | `PHONE_ALREADY_EXISTS` | Phone is already registered. |
| Weak / mismatch password | 422 | `PASSWORD_INVALID` / `PASSWORD_MISMATCH` | User-facing rule text |
| Invalid credentials | 401 | `INVALID_CREDENTIALS` | Email or password is incorrect. |
| Unauthorized | 401 | `UNAUTHORIZED` | Authentication required. |
| Invalid/expired refresh | 401 | `REFRESH_TOKEN_INVALID` | Refresh token is invalid or expired. |
| Refresh reuse | 401 | `REFRESH_TOKEN_REUSE` | Refresh token reuse detected. |
| Not found (profile image) | 404 | `PROFILE_IMAGE_NOT_FOUND` | Profile image not found. |
| Unsupported media | 415/422 | `INVALID_IMAGE` | Profile image must be JPEG, PNG, or WebP. |

## Application Use Cases (map to stories)

| Story | Use cases |
|-------|-----------|
| 001 | App factory, `/api/v1` router, health, exception handlers, DB session, Alembic, auth dependency stub/real, PageMeta helpers |
| 002 | `RegisterOwner` — validate, hash, store image, persist owner + farm_settings |
| 003 | `SignIn`, `SignOut`, `RefreshTokens` — JWT issue/rotate/revoke + reuse detection |
| 004 | `Get/UpdateProfile`, `Get/UpdateFarmSettings`, suggested-units config |

## Integrations

| Service | Purpose | Integration |
|---------|---------|-------------|
| PostgreSQL | System of record | SQLAlchemy async or sync (prefer **sync** SQLAlchemy 2 + FastAPI for v1 simplicity unless project already async) |
| Local filesystem | Profile images | `ProfileImageStore` port |
| Env config | Secrets & paths | pydantic-settings |

**Decision**: Use **sync** SQLAlchemy 2.x + dependency-injected session for v1 simplicity (single owner, local Postgres). Revisit async if needed later.

## Testing Plan (preview for Stage 5)

- Unit: password rules, email normalization, refresh rotation/reuse state machine
- API: health, signup happy/dup/validation, signin/signout/refresh, profile/settings authz
- Security: private route without token → `UNAUTHORIZED`; secrets absent from logs in tests where asserted

## Out of Scope (this bolt)

- React / Flutter UI (bolts 002 / 003)
- Docker / hosting / object storage
- Multi-owner, staff, RBAC
- Domain modules (cows, etc.)
