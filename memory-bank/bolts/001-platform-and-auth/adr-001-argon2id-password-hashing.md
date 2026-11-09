---
bolt: 001-platform-and-auth
created: 2026-11-09T09:25:51Z
status: accepted
superseded_by: null
---

# ADR-001: Use Argon2id for Password Hashing

## Context

Standards allow either Argon2 or bcrypt for owner password hashing. Construction must pick one algorithm and library so signup, sign-in, and any future credential resets stay consistent across the FastAPI monolith.

## Decision

Use **Argon2id** for hashing and verifying owner passwords, via `argon2-cffi` (or an equivalent thin wrapper such as `pwdlib` configured for Argon2id). Never store or log plaintext passwords.

## Rationale

Argon2id is the modern PHC winner and resists both side-channel and GPU cracking better than bcrypt for new systems. Standards already list Argon2 as an acceptable option; locking Argon2id avoids mixed hashes in the `owners.password_hash` column.

### Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| bcrypt | Ubiquitous, well understood | Weaker against modern hardware; standards already allow Argon2 | Prefer stronger default for a long-lived personal farm app |
| Argon2i / Argon2d only | Specialized variants | Argon2id is the recommended hybrid for password hashing | Use Argon2id as the general-purpose choice |

## Consequences

### Positive

- One clear hashing standard for all auth code and tests
- Aligns with security guidance in system-architecture

### Negative

- Slightly less “copy-paste from bcrypt tutorials” familiarity for contributors

### Risks

- Library API churn — mitigate by isolating hashing behind a `PasswordHasher` port

## Related

- **Stories**: 002-api-owner-signup, 003-api-owner-signin-signout
- **Standards**: system-architecture (passwords hashed Argon2 or bcrypt), coding-standards (never log secrets)
- **Previous ADRs**: none
