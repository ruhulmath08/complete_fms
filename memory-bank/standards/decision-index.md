---
last_updated: 2026-11-09T09:25:51Z
total_decisions: 3
---

# Decision Index

This index tracks all Architecture Decision Records (ADRs) created during Construction bolts.
Use this to find relevant prior decisions when working on related features.

## How to Use

**For Agents**: Scan the "Read when" fields below to identify decisions relevant to your current task. Before implementing new features, check if existing ADRs constrain or guide your approach. Load the full ADR for matching entries.

**For Humans**: Browse decisions chronologically or search for keywords. Each entry links to the full ADR with complete context, alternatives considered, and consequences.

---

## Decisions

### ADR-003: Refresh Token Rotation with family_id Reuse Wipe
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 001-platform-and-auth (001-platform-and-auth)
- **Path**: `bolts/001-platform-and-auth/adr-003-refresh-token-family-reuse.md`
- **Summary**: Standards require refresh rotation and reuse detection but not the Postgres tracking model. Persist hashed JWT refresh tokens, group rotation chains by `family_id`, and revoke the entire family on reuse.
- **Read when**: Working on authentication flows, session management, sign-in/sign-out/refresh endpoints, or token security tests

### ADR-002: Use Sync SQLAlchemy 2.x for v1
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 001-platform-and-auth (001-platform-and-auth)
- **Path**: `bolts/001-platform-and-auth/adr-002-sync-sqlalchemy-v1.md`
- **Summary**: Data stack requires SQLAlchemy 2.x but not sync vs async. Use synchronous SQLAlchemy sessions for v1 simplicity behind repository ports.
- **Read when**: Implementing database access, repositories, Alembic migrations, or FastAPI DB dependencies in any API module

### ADR-001: Use Argon2id for Password Hashing
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 001-platform-and-auth (001-platform-and-auth)
- **Path**: `bolts/001-platform-and-auth/adr-001-argon2id-password-hashing.md`
- **Summary**: Standards allow Argon2 or bcrypt for password hashing. Lock Argon2id via `argon2-cffi` / equivalent behind a PasswordHasher port.
- **Read when**: Working on signup, sign-in, password verification, or credential storage
