---
unit: 001-platform-and-auth
bolt: 001-platform-and-auth
stage: model
status: complete
updated: 2026-11-09T09:14:44Z
---

# Static Model - Platform and Auth

## Bounded Context

**Platform & Auth** owns the single-farm owner identity, credential lifecycle (sign-up, sign-in, sign-out, refresh), profile and farm settings, and the shared API platform primitives other domain modules rely on (versioned routing baseline, consistent errors, authz hooks, paging meta).

This context does **not** own cows, poultry, crops, inventory, or income/expense records; those depend on the authenticated Owner identity established here.

**v1 assumptions**: one farm, one owner account, no staff/RBAC, no multi-farm.

## Domain Entities

| Entity | Properties | Business Rules |
|--------|------------|----------------|
| Owner | id, full_name, email, phone, address, location (lat/lng), profile_image_path, password_hash, created_at, updated_at | Exactly one owner identity for the farm in v1. Email and phone must each be unique. Email format must be valid. Password is never stored plaintext — only a secure hash. All signup profile fields are required. On profile update, duplicate email/phone against another account is rejected. |
| FarmSettings | id, owner_id, currency_code, created_at, updated_at | One FarmSettings record per Owner. Default currency_code is `BDT` at creation; owner may change it. No FX conversion in v1. Suggested quantity units (kg, L, pcs, …) are reference config, not persisted as currency. |
| RefreshToken | id, owner_id, token_hash, expires_at, revoked_at, replaced_by_token_id?, created_at, last_used_at? | Issued on successful sign-in (and on successful refresh). Stored as hash only. Rotation: presenting a valid refresh issues a new token and revokes/supersedes the old one. Reuse of an already-rotated or revoked token is detected and treated as compromise — invalidate the affected token family / session chain for that owner credential set. Sign-out revokes active refresh credentials. |

## Value Objects

| Value Object | Properties | Constraints |
|--------------|------------|-------------|
| EmailAddress | value | Valid email format; compared case-insensitively for uniqueness |
| PhoneNumber | value | Required non-empty string; unique across owners |
| GeoLocation | latitude, longitude | Both required on signup/profile; represent owner location |
| Password | plaintext (transient only) | ≥8 characters; at least one letter and one number; confirm must match on signup; never persisted |
| PasswordHash | algorithm, hash | Opaque credential material; never logged or returned in API |
| CurrencyCode | value | Non-empty; initial default `BDT`; free-form code string in v1 (no ISO enforcement beyond non-empty) |
| ProfileImageRef | storage_path | Points to local-disk upload outside Git; required on signup; updatable |
| AccessTokenClaims | subject (owner_id), issued_at, expires_at, type=access | Short-lived; authorizes private routes |
| RefreshTokenClaims | subject (owner_id), jti/token_id, issued_at, expires_at, type=refresh | Longer-lived; used only to obtain new access (+ rotated refresh) |
| ApiError | code, message, details? | Stable `code` for clients; user-facing `message`; optional `details` (e.g. field errors) |
| PageMeta | total, limit, offset | Shared list paging shape for later list endpoints |

## Aggregates

| Aggregate Root | Members | Invariants |
|----------------|---------|------------|
| Owner | Owner profile fields; association to FarmSettings (1:1); collection of RefreshToken credentials | Owner email unique; Owner phone unique; password_hash always present after signup; FarmSettings exists for owner after signup (currency defaults to BDT); profile image ref required; cannot expose password or refresh token plaintext |
| RefreshSession (credential) | RefreshToken rows belonging to an Owner | Only non-revoked, non-expired tokens authorize refresh; rotation supersedes prior token; reuse of rotated/revoked token fails closed and tears down the compromised chain |

**Aggregate note**: FarmSettings is owned by the Owner aggregate for consistency of “owner has farm preferences.” RefreshToken may be modeled as a child of Owner or as its own credential aggregate with Owner as identity reference; either way, revocation/reuse rules are enforced inside the Auth domain service.

## Domain Events

| Event | Trigger | Payload |
|-------|---------|---------|
| OwnerRegistered | Successful signup | owner_id, email, phone, registered_at |
| OwnerSignedIn | Successful credential check | owner_id, signed_in_at |
| OwnerSignedOut | Explicit sign-out | owner_id, signed_out_at |
| RefreshTokenRotated | Successful refresh | owner_id, old_token_id, new_token_id |
| RefreshTokenReuseDetected | Presented refresh already rotated/revoked | owner_id, token_id, detected_at |
| OwnerProfileUpdated | Profile fields/image changed | owner_id, changed_fields, updated_at |
| FarmSettingsUpdated | Currency (or other settings) changed | owner_id, currency_code, updated_at |

Events are domain facts for logging/audit and future integrations; v1 may record via application logging without an event bus.

## Domain Services

| Service | Operations | Dependencies |
|---------|------------|--------------|
| RegistrationService | register_owner(signup_data, profile_image) | OwnerRepository, FarmSettingsRepository, PasswordHasher, ProfileImageStore |
| AuthenticationService | sign_in(email, password); sign_out(owner, refresh_token?); refresh(refresh_token) | OwnerRepository, RefreshTokenRepository, PasswordHasher, TokenIssuer |
| ProfileService | get_profile(owner_id); update_profile(owner_id, changes, optional image) | OwnerRepository, ProfileImageStore |
| FarmSettingsService | get_settings(owner_id); update_currency(owner_id, currency_code) | FarmSettingsRepository |
| AuthorizationPolicy | require_authenticated_owner(access_token) → Owner identity | TokenVerifier |

**RegistrationService rules**: validate all required fields; validate email/password/confirm; reject duplicate email/phone; hash password; persist Owner + default FarmSettings; store profile image on disk.

**AuthenticationService rules**: verify password against hash; issue access + refresh JWTs; on sign-out revoke refresh; on refresh rotate with reuse detection.

## Repository Interfaces

| Repository | Entity | Methods |
|------------|--------|---------|
| OwnerRepository | Owner | save(owner); get_by_id(id); get_by_email(email); get_by_phone(phone); exists_email(email, exclude_id?); exists_phone(phone, exclude_id?) |
| FarmSettingsRepository | FarmSettings | save(settings); get_by_owner_id(owner_id) |
| RefreshTokenRepository | RefreshToken | save(token); get_by_token_hash(hash); list_active_by_owner(owner_id); revoke(token_id); revoke_all_for_owner(owner_id); mark_replaced(old_id, new_id) |

**Ports (non-repo)**:

| Port | Purpose |
|------|---------|
| PasswordHasher | hash(password) → PasswordHash; verify(password, hash) → bool |
| TokenIssuer / TokenVerifier | issue access/refresh; verify and parse claims |
| ProfileImageStore | store(file) → ProfileImageRef; replace(old, file) → ProfileImageRef |

## Platform Primitives (Story 001)

Not rich domain entities, but required shared concepts this bounded context establishes for the monolith:

| Primitive | Responsibility |
|-----------|----------------|
| ApiPlatform | FastAPI app bootstrap, `/api/v1` routing, health/OpenAPI reachability, Alembic-ready persistence hook |
| AuthMiddlewareHook | Reject unauthenticated private requests with ApiError shape |
| PaginationPattern | Offset/limit + PageMeta for list endpoints |

## Ubiquitous Language

| Term | Definition |
|------|------------|
| Owner | The single authenticated farm account identity for v1 |
| Farm | The one farm managed by the Owner (implicit; no multi-farm entity yet) |
| Farm Settings | Owner preferences for the farm, including currency_code |
| Sign-up / Register | Creating the Owner account with required profile + password |
| Sign-in | Exchanging email/password for access and refresh tokens |
| Sign-out | Ending the authenticated session by revoking refresh credentials |
| Access Token | Short-lived JWT authorizing private API calls |
| Refresh Token | Longer-lived credential used only to obtain a new access token (and rotated refresh) |
| Refresh Rotation | Issuing a new refresh and invalidating the previous one on each use |
| Reuse Detection | Treating a second use of an already-rotated/revoked refresh as compromise |
| Profile Image | Owner photo stored on local disk outside Git; referenced by path |
| Private Route | Any API endpoint that requires a valid Owner access token |
| Api Error | Stable `{code, message, details?}` error body shared by all API modules |
| Currency Code | Single farm currency preference; defaults to BDT |

## Story Coverage

| Story | Domain coverage |
|-------|-----------------|
| 001-api-platform-foundation | ApiPlatform, AuthMiddlewareHook, ApiError, PageMeta |
| 002-api-owner-signup | Owner, Password/PasswordHash, ProfileImageRef, RegistrationService, FarmSettings default |
| 003-api-owner-signin-signout | AuthenticationService, Access/Refresh tokens, RefreshToken aggregate rules, AuthorizationPolicy |
| 004-api-profile-farm-settings | ProfileService, FarmSettingsService, uniqueness on email/phone update, CurrencyCode |

## Open Questions Deferred to Technical Design

- Exact access/refresh TTLs
- Exact local upload folder path
- Final suggested units list (static config)
- Password hash algorithm choice within Argon2/bcrypt (standards allow either)
