---
bolt: 001-platform-and-auth
created: 2026-11-09T09:25:51Z
status: accepted
superseded_by: null
---

# ADR-003: Refresh Token Rotation with family_id Reuse Wipe

## Context

Standards require JWT access + refresh tokens with short-lived access, refresh rotation, and reuse detection. They do not specify how rotation chains are tracked in Postgres or what “reuse detection” does to sibling tokens. Web and mobile both rely on refresh; a stolen refresh replay must fail closed.

## Decision

1. Issue JWT refresh tokens and persist a **hash** of the raw token string in `refresh_tokens`.
2. Group each sign-in rotation chain with a shared **`family_id`**.
3. On successful refresh: revoke the presented token, store `replaced_by_token_id`, issue a new refresh in the same family.
4. On reuse of a revoked/rotated refresh: **revoke all tokens in that `family_id`** and return `401` with `REFRESH_TOKEN_REUSE`.
5. Sign-out revokes the presented refresh and/or all active tokens for the owner as designed in the technical design.

## Rationale

Hash storage prevents DB leaks from yielding usable refresh tokens. `family_id` makes reuse detection actionable: any replay after rotation invalidates the whole chain, not just one row. This matches the “harder token rules” security posture in system-architecture without adding Redis or opaque-only tokens.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Opaque refresh only in DB | Simple server lookup | Loses self-contained expiry/claims convenience; still need rotation tables | JWT + hash gives verify + revocation |
| Rotate without family wipe | Less aggressive | Stolen token can race; weaker reuse story | Fails closed preferred for personal farm app |
| No server-side refresh store | Stateless simplicity | Cannot revoke or detect reuse reliably | Conflicts with standards |

## Consequences

### Positive

- Clear, testable rotation/reuse state machine
- Aligns multi-client JWT strategy with revoke-on-compromise behavior

### Negative

- Extra table and hash/compare logic on every refresh

### Risks

- Clock skew / concurrent refresh from two devices in same family — mitigate with last-write rotation semantics and documenting that concurrent refresh may force re-login if one loses the race

## Related

- **Stories**: 003-api-owner-signin-signout
- **Standards**: tech-stack.md, system-architecture.md (JWT, rotation, reuse detection)
- **Previous ADRs**: none
