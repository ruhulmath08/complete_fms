---
unit: 001-platform-and-auth
intent: 001-farm-management-first-release
phase: inception
status: complete
created: '2026-11-09T06:55:29Z'
updated: '2026-11-09T06:55:29Z'
unit_type: vertical-slice
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: Platform and Auth

## Purpose

Shared API foundation plus owner authentication, profile, farm settings, and owner-only access patterns used by both clients.

## Scope

### In Scope
- API endpoints and persistence for this domain
- React web screens for this domain
- Flutter mobile screens for this domain
- OpenAPI/contract documentation before client wiring

### Out of Scope
- Other domain modules (handled by sibling units)
- Hosting / Docker / object storage migration

---

## Assigned Requirements

| FR | Requirement | Priority |
|----|-------------|----------|
| FR-1 | Owner sign-up | Must |
| FR-2 | Owner sign-in and sign-out | Must |
| FR-3 | Profile and farm settings | Must |
| FR-12 | Shared API contract for web and mobile | Must |
| FR-13 | Owner-only access to farm data | Must |

---

## Domain Concepts

### Key Entities
| Entity | Description | Attributes |
|--------|-------------|------------|
| Owner | Authenticated farm owner account | email, phone, name, address, location, password_hash, profile_image |
| FarmSettings | Single-farm settings | currency_code default BDT |
| RefreshToken | Rotated refresh credential | token hash, expiry, revoked/reuse flags |

### Key Operations
| Operation | Description | Inputs | Outputs |
|-----------|-------------|--------|---------|
| Manage records | CRUD/archive and related sub-records | Owner JWT + payloads | JSON resources / errors |

---

## Story Summary

| Metric | Count |
|--------|-------|
| Total Stories | 6 |
| Must Have | 6 |
| Should Have | 0 |
| Could Have | 0 |

### Stories

| Story ID | Title | Priority | Status |
|----------|-------|----------|--------|
| 001-api-platform-foundation | API platform foundation | Must | Planned |
| 002-api-owner-signup | API owner sign-up | Must | Planned |
| 003-api-owner-signin-signout | API owner sign-in and sign-out | Must | Planned |
| 004-api-profile-farm-settings | API profile and farm settings | Must | Planned |
| 005-web-auth-and-settings | Web auth and settings | Must | Planned |
| 006-mobile-auth-and-settings | Mobile auth and settings | Must | Planned |

---

## Dependencies

### Depends On
| Unit | Reason |
|------|--------|
| None | — |

### Depended By
| Unit | Reason |
|------|--------|
| 002-cows | Uses auth and API conventions |
| 003-poultry | Uses auth and API conventions |
| 004-crops | Uses auth and API conventions |
| 005-inventory | Uses auth and API conventions |
| 006-income-expenses | Uses auth and API conventions |

### External Dependencies
| System | Purpose | Risk |
|--------|---------|------|
| PostgreSQL | Persistence | Low |
| Local disk | Profile images (auth unit) | Low |

---

## Technical Context

### Suggested Technology
FastAPI + SQLAlchemy + Alembic; React Vite + TanStack Query; Flutter Clean Arch/BLoC; JWT per standards.

### Integration Points
| Integration | Type | Protocol |
|-------------|------|----------|
| `/api/v1` | API | REST JSON |
| Web/Mobile clients | Consumer | JWT Bearer |

### Data Storage
| Data | Type | Volume | Retention |
|------|------|--------|-----------|
| Domain tables | PostgreSQL | Single farm | Indefinite for v1 |

---

## Constraints

- Follow vertical order API → web → mobile within this unit
- Keep API error/success shapes consistent with api-conventions
- Owner-only data access

---

## Success Criteria

### Functional
- [ ] All assigned FRs satisfied on API, web, and mobile
- [ ] Contract documented before client screens

### Non-Functional
- [ ] Authz enforced on private routes
- [ ] No secrets in logs

### Quality
- [ ] Critical-path tests per coding-standards
- [ ] All story acceptance criteria met

---

## Bolt Suggestions

| Bolt | Type | Stories | Objective |
|------|------|---------|-----------|
| API bolt | ddd-construction-bolt | API stories | Domain + API |
| Web bolt | simple-construction-bolt | Web stories | React feature UI |
| Mobile bolt | simple-construction-bolt | Mobile stories | Flutter feature UI |

---

## Notes

Unresolved implementation details stay in requirements Open Questions until Construction decides them.
