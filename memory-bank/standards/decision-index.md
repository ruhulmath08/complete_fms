---
last_updated: 2026-11-09T10:29:56Z
total_decisions: 6
---

# Decision Index

This index tracks all Architecture Decision Records (ADRs) created during Construction bolts.
Use this to find relevant prior decisions when working on related features.

## How to Use

**For Agents**: Scan the "Read when" fields below to identify decisions relevant to your current task. Before implementing new features, check if existing ADRs constrain or guide your approach. Load the full ADR for matching entries.

**For Humans**: Browse decisions chronologically or search for keywords. Each entry links to the full ADR with complete context, alternatives considered, and consequences.

---

## Decisions

### ADR-006: Tag Uniqueness Among Active Cows Only
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 004-cows (002-cows)
- **Path**: `bolts/004-cows/adr-006-active-cow-tag-uniqueness.md`
- **Summary**: Standards do not define tag reuse after archive. Enforce unique `(owner_id, tag_number)` only for active cows via a partial unique index; archived tags may be reused; identity for history is `cow_id`.
- **Read when**: Implementing cow create/update/archive, tag validation, or livestock identity uniqueness rules

### ADR-005: Denormalize owner_id on Child Event Tables
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 004-cows (002-cows)
- **Path**: `bolts/004-cows/adr-005-denormalized-owner-id-on-child-tables.md`
- **Summary**: Standards require owner-only authorization but not how child rows store scope. Persist `owner_id` on milk/feeding (and similar) tables and filter every child query by it, in addition to parent cow checks.
- **Read when**: Implementing child/event tables under a parent aggregate, owner isolation queries, or repository patterns for production logs

### ADR-004: Soft-Archive Livestock with Write Block (No Unarchive in v1)
- **Status**: accepted
- **Date**: 2026-11-09
- **Bolt**: 004-cows (002-cows)
- **Path**: `bolts/004-cows/adr-004-soft-archive-livestock.md`
- **Summary**: Standards do not define livestock retirement. Soft-archive via `is_archived`, allow GET of archived, block writes with `COW_ARCHIVED`, and omit unarchive in v1.
- **Read when**: Implementing cow/poultry/livestock lifecycle, archive endpoints, or write guards on retired animals

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
