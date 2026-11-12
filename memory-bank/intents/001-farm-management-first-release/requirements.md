---
intent: 001-farm-management-first-release
phase: inception
status: complete
created: '2026-11-09T06:34:30Z'
updated: '2026-11-09T06:59:56Z'
---

# Requirements: Farm Management First Release

## Intent Overview

Deliver the first release of a farm management system for **one farm** and **one owner account**. The owner can sign up, sign in, manage profile and farm settings, and keep records for cows, poultry, crops, inventory, and general income/expenses. Delivery includes a shared FastAPI backend, a React (Vite) web app, and a Flutter mobile app. This is basic record keeping — not full accounting or forecasting.

## Business Goals

| Goal | Success Metric | Priority |
|------|----------------|----------|
| Owner keeps farm records in one system | Owner completes main workflows on web and mobile against one API | Must |
| Single-farm, single-owner scope | No multi-farm or staff/role features ship in this release | Must |
| Consistent rules across clients | Web and mobile use the same backend validation, authorization, and error codes | Must |
| First-release acceptance | Checklist in `specs.md` §13 and `specs/08-first-release-checklist.md` is satisfied | Must |

---

## Functional Requirements

### FR-1: Owner sign-up
- **Description**: A new owner can create an account with profile image, full name, email, phone, address, location (latitude/longitude), password, and confirm password. All fields are required. Email format is validated. Password must be at least 8 characters and include at least one letter and one number. Password and confirm password must match; only a secure password hash is stored. Duplicate email and duplicate phone are rejected. Profile images are stored on local disk under a documented upload path outside Git for development.
- **Acceptance Criteria**:
  - Sign-up succeeds when all required fields are valid and unique
  - Invalid email, weak password, mismatched confirmation, duplicate email, or duplicate phone are rejected with consistent API error codes/messages
  - Password plaintext is never stored or logged
  - Profile image is stored under the documented local upload path and is not committed to Git
- **Priority**: Must
- **Related Stories**: TBD after story creation

### FR-2: Owner sign-in and sign-out
- **Description**: The owner signs in with email and password and receives JWT access and refresh tokens (short-lived access token; refresh rotation with reuse detection per standards). The owner can sign out. Signed-out users cannot access private farm data.
- **Acceptance Criteria**:
  - Valid credentials return tokens usable by web and mobile
  - Invalid credentials are rejected without leaking whether email exists beyond a safe message policy
  - After sign-out (and without a valid access token), private endpoints return unauthorized
  - Refresh rotation and reuse detection behave as defined in system-architecture standards
- **Priority**: Must
- **Related Stories**: TBD

### FR-3: Profile and farm settings
- **Description**: The signed-in owner can view and update profile image, full name, email, phone, address, location (latitude/longitude), and farm settings including the single currency code (initial default `BDT`, editable). Unit suggestions (e.g. kg, L, pcs) are available where quantities are recorded; units are free-text from a suggested list with no currency conversion.
- **Acceptance Criteria**:
  - Owner can view and update all listed profile fields
  - Currency code defaults to `BDT` and can be changed in farm settings
  - Duplicate email/phone rules still apply on update
  - Changes are available to both web and mobile via the API
- **Priority**: Must
- **Related Stories**: TBD

### FR-4: Cow records
- **Description**: The owner can add, view, edit, and archive cow records with tag number; optional name, breed, date of birth, color, weight, age; purpose (milk, meat, or both); gender; acquired by (purchased or born on farm); purchase date/price only when purchased; and notes.
- **Acceptance Criteria**:
  - CRUD + archive for cow records works for the signed-in owner
  - Purchase date and price apply only when acquired-by is purchased
  - Meat-only cows do not require milk records
- **Priority**: Must
- **Related Stories**: TBD

### FR-5: Cow milk production and feeding
- **Description**: For milk-purpose cows (milk or both), the owner can record milk production (date/time, quantity, unit, price per unit, optional note) and review entries. For any cow, the owner can record feeding (date/time, feed type/name, quantity, unit, optional note) and review entries.
- **Acceptance Criteria**:
  - Milk entries can be created and listed per eligible cow
  - Feeding entries can be created and listed per cow
  - Meat-only cows are not required to have milk production
- **Priority**: Must
- **Related Stories**: TBD

### FR-6: Poultry groups and bird counts
- **Description**: The owner can add, view, edit, and archive poultry groups (type: broiler, duck, layer, or local; name/identifier; bird count; optional date acquired; acquired by purchased/born; purchase date/price when purchased; notes) and update bird counts when birds are added or removed.
- **Acceptance Criteria**:
  - CRUD + archive for poultry groups works
  - Bird count can be updated
  - Purchase fields apply only when purchased
- **Priority**: Must
- **Related Stories**: TBD

### FR-7: Poultry feeding and egg production
- **Description**: The owner can record and review feeding for any poultry group. For layer, duck, or local groups, the owner can record and review egg production (date/time, quantity, unit, price per unit, optional note). Broilers do not require egg production.
- **Acceptance Criteria**:
  - Feeding works for all group types
  - Egg production works for layer, duck, and local
  - Broiler groups are not required to have egg records
- **Priority**: Must
- **Related Stories**: TBD

### FR-8: Crop names and crop cycles
- **Description**: Crop names are managed separately (add, view, edit, archive). A crop cycle must select a crop name from that list (not free text) and may include field/plot name, optional area, optional location, planting date, optional expected harvest date, and notes. Cycles support add, view, edit, archive.
- **Acceptance Criteria**:
  - Crop names are independently manageable
  - Creating/editing a cycle requires a selected crop name from the list
  - Cycle CRUD + archive works
- **Priority**: Must
- **Related Stories**: TBD

### FR-9: Crop expenses, harvests, and summary
- **Description**: The owner can add and review expenses linked to a crop cycle (date, category from Labour / Fertilizers / Pesticides and chemicals / Seeds / Irrigation / Equipment / Other, amount, optional note). The owner can record harvests (date, quantity, unit, optional sale amount, optional note). Each cycle shows total recorded expenses, recorded sale income, and simple result (income minus expenses).
- **Acceptance Criteria**:
  - Expenses and harvests can be recorded and reviewed per cycle
  - Summary matches entered records only (not full accounting)
  - Crop expenses are not double-counted in general expenses (see FR-11)
- **Priority**: Must
- **Related Stories**: TBD

### FR-10: Inventory and stock updates
- **Description**: The owner can add, view, edit, and archive inventory items (name, category, quantity, unit, price per unit, total price, optional note) and record stock added or used (date, quantity change, reason/note). Displayed quantity reflects stock updates. A stock update must not reduce quantity below zero.
- **Acceptance Criteria**:
  - Item CRUD + archive works
  - Stock updates adjust displayed quantity
  - Updates that would go below zero are rejected with a stable error code
- **Priority**: Must
- **Related Stories**: TBD

### FR-11: General income and expenses
- **Description**: The owner can add, view, edit, and archive general income/expense entries (type, date, category, amount, unit, total price, optional note), view by date, and see simple totals for a selected period. Crop-module expenses must not be counted again as general expenses.
- **Acceptance Criteria**:
  - Entry CRUD + archive works
  - Period totals for income and expenses are correct for selected range
  - Guidance/rules keep crop expenses in the Crops module only
- **Priority**: Must
- **Related Stories**: TBD

### FR-12: Shared API contract for web and mobile
- **Description**: FastAPI exposes `/api/v1` REST JSON used by React and Flutter. Each feature’s request/response fields, validation, and errors are documented before dependent client screens. Success and error shapes follow `api-conventions` and coding-standards. Both clients can complete the main workflows against the same rules.
- **Acceptance Criteria**:
  - OpenAPI (or equivalent feature docs) exists before client wiring for each slice
  - Same error `code` / `message` / optional `details` consumed by both clients
  - First-release checklist items for web, mobile, and shared backend rules pass
- **Priority**: Must
- **Related Stories**: TBD

### FR-13: Owner-only access to farm data
- **Description**: Private farm data is available only to the signed-in owner. There are no staff accounts or roles in this release.
- **Acceptance Criteria**:
  - Unauthenticated requests to private resources fail
  - Authenticated owner can only access their own farm’s data
  - No staff/role management endpoints or UI in this intent
- **Priority**: Must
- **Related Stories**: TBD

---

## Non-Functional Requirements

### Performance
| Requirement | Metric | Target |
|-------------|--------|--------|
| Interactive API responses (local) | p95 latency for typical CRUD | < 500ms on local Postgres for single-owner workloads |
| List endpoints | p95 for default page size | < 1s locally for expected single-farm volumes |

### Scalability
| Requirement | Metric | Target |
|-------------|--------|--------|
| Users | Concurrent owners | 1 owner account in v1 |
| Farms | Farms per deployment | 1 farm in v1 |
| Data volume | Records | Sized for one working farm; pagination on growing lists |

### Security
| Requirement | Standard | Notes |
|-------------|----------|-------|
| Authentication | JWT access + refresh | Short access TTL; refresh rotation + reuse detection |
| Passwords | Min 8 chars, ≥1 letter, ≥1 number; hashed | Confirm match on sign-up; never store plaintext |
| Authorization | Owner-only | No RBAC/staff in v1 |
| Uploads | Local disk outside Git | Path documented for later object-storage swap |
| Logging | No secrets | Never log passwords, tokens, or raw credentials |

### Reliability
| Requirement | Metric | Target |
|-------------|--------|--------|
| Data durability (dev) | Postgres persistence | Survives API process restart |
| Migrations | Alembic | Schema changes are versioned and apply cleanly locally |

### Usability / clients
| Requirement | Standard | Notes |
|-------------|----------|-------|
| Visual consistency | Shared tokens + Material 3 | Per ux-guide |
| Mobile locales | Bangla + English | Flutter localization |
| Responsive web | Phone browser through desktop | Per ux-guide |

### Compliance
| Requirement | Standard | Notes |
|-------------|----------|-------|
| None mandated for v1 | — | No regulatory pack in this intent |

---

## Constraints

### Technical Constraints

**Project-wide standards**: Loaded from `memory-bank/standards/` by Construction Agent (tech-stack, data-stack, coding-standards, system-architecture, ux-guide, api-conventions).

**Intent-specific constraints**:
- One farm, one owner only
- Backend + React web + Flutter mobile all in scope
- Local development without Docker; hosting TBD
- Vertical slices after shared foundation, order: auth/settings → cows → poultry → crops → inventory → income/expenses; each slice covers API, then web, then mobile before the next domain
- Document API contract per feature before client screens
- Profile uploads on local disk; not in Git; path documented for deploy swap
- Single currency code (default `BDT`, editable); suggested unit labels; no FX conversion
- Out of scope: multi-farm, staff/roles, advanced accounting, forecasting, complex reporting

### Business Constraints
- First-release checklist is the acceptance bar
- Keep infrastructure simple for v1
- No Construction / feature code until inception artifacts are approved and Construction is explicitly started

---

## Assumptions

| Assumption | Risk if Invalid | Mitigation |
|------------|-----------------|------------|
| `specs.md` and `specs/*` remain the product source of truth | Drift between specs and requirements | Keep Open Questions updated; revise requirements on change |
| One owner never needs concurrent multi-device conflict resolution beyond last-write API semantics | Confusing overwrites | Document last-write-wins for v1; revisit later |
| Suggested unit list is enough without a rigid units taxonomy | Inconsistent labels | Provide suggestions; allow free-text within reason |
| Local upload path is acceptable until deploy | Lost files on machine change | Document path; plan object storage at deploy |

---

## Open Questions (unresolved implementation details)

| Question | Owner | Status | Notes |
|----------|-------|--------|-------|
| Exact local upload directory name/layout and static serving rules | Construction (auth/settings bolt) | Pending | Decision: local disk, out of Git, documented path; exact folder TBD |
| Access token TTL and refresh token lifetime numeric values | Construction (auth bolt) | Pending | Standards require short access TTL + rotation; exact durations TBD |
| Password hash algorithm choice (Argon2 vs bcrypt) and library | Construction (auth bolt) | Pending | Must be a secure hash; algorithm TBD |
| Canonical suggested units list contents | Construction (settings / first quantity feature) | Pending | Examples include kg, L, pcs; final list TBD |
| Whether inventory `total_price` is stored, computed, or both | Construction (inventory bolt) | Pending | Specs list both price per unit and total price |
| Whether general income/expense `total_price` vs `amount` semantics need tighter rules | Construction (income/expenses bolt) | Pending | Specs list both fields |
| Exact pagination default `limit` | Construction (platform/API) | Pending | Offset/limit required; default size TBD |
| Web Bangla localization depth in v1 | Product owner / UX | Pending | Mobile requires Bangla+English; web “where practical” |
| When/how hosting and object storage are chosen | Later deploy / Operations | Deferred | Explicitly out of this inception Construction gate |

---

## Out of Scope (Won't for this intent)

- Multiple farms
- Multiple owner accounts or staff roles
- Advanced accounting
- Forecasting
- Complex reporting
- Currency conversion
- Docker-based local stack
- Production hosting selection
