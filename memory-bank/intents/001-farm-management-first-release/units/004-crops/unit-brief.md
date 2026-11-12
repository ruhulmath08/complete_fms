---
unit: 004-crops
intent: 001-farm-management-first-release
phase: inception
status: complete
created: '2026-11-09T06:55:29Z'
updated: '2026-11-09T06:55:29Z'
unit_type: vertical-slice
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: Crops

## Purpose

Crop names, cycles, expenses, harvests, and simple summaries via API, web, and mobile.

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
| FR-8 | Crop names and crop cycles | Must |
| FR-9 | Crop expenses, harvests, and summary | Must |

---

## Domain Concepts

### Key Entities
| Entity | Description | Attributes |
|--------|-------------|------------|
| CropName | Managed crop name catalog entry | name, archived |
| CropCycle | Planted cycle referencing CropName | plot, area, location, dates, notes |
| CropExpense | Expense on a cycle | date, category, amount, note |
| Harvest | Harvest record | date, quantity, unit, sale_amount, note |

### Key Operations
| Operation | Description | Inputs | Outputs |
|-----------|-------------|--------|---------|
| Manage records | CRUD/archive and related sub-records | Owner JWT + payloads | JSON resources / errors |

---

## Story Summary

| Metric | Count |
|--------|-------|
| Total Stories | 4 |
| Must Have | 4 |
| Should Have | 0 |
| Could Have | 0 |

### Stories

| Story ID | Title | Priority | Status |
|----------|-------|----------|--------|
| 001-api-crop-names-and-cycles | API crop names and cycles | Must | Planned |
| 002-api-crop-expenses-harvests-summary | API crop expenses harvests summary | Must | Planned |
| 003-web-crops | Web crops workflows | Must | Planned |
| 004-mobile-crops | Mobile crops workflows | Must | Planned |

---

## Dependencies

### Depends On
| Unit | Reason |
|------|--------|
| 001-platform-and-auth | Prior vertical slice / auth foundation |

### Depended By
| Unit | Reason |
|------|--------|
| None | — |

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
