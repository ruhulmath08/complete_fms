---
intent: 001-farm-management-first-release
phase: inception
status: units-decomposed
updated: 2026-11-09T06:55:29Z
---

# Farm Management First Release - Unit Decomposition

## Units Overview

This intent decomposes into **6 vertical-slice units**. Each unit delivers API, then web, then mobile for its domain before the next domain starts Construction sequencing.

### Unit 1: `001-platform-and-auth`

**Description**: Shared API foundation plus owner authentication, profile, farm settings, and owner-only access patterns used by both clients.

**Assigned FRs**: FR-1, FR-2, FR-3, FR-12, FR-13

**Dependencies**:
- Depends on: None
- Depended by: `002-cows`, `003-poultry`, `004-crops`, `005-inventory`, `006-income-expenses`

**Estimated Complexity**: M

### Unit 2: `002-cows`

**Description**: Cow records, milk production, and feeding via API, web, and mobile.

**Assigned FRs**: FR-4, FR-5

**Dependencies**:
- Depends on: `001-platform-and-auth`
- Depended by: None

**Estimated Complexity**: M

### Unit 3: `003-poultry`

**Description**: Poultry groups, bird counts, feeding, and egg production via API, web, and mobile.

**Assigned FRs**: FR-6, FR-7

**Dependencies**:
- Depends on: `001-platform-and-auth`
- Depended by: None

**Estimated Complexity**: M

### Unit 4: `004-crops`

**Description**: Crop names, cycles, expenses, harvests, and simple summaries via API, web, and mobile.

**Assigned FRs**: FR-8, FR-9

**Dependencies**:
- Depends on: `001-platform-and-auth`
- Depended by: None

**Estimated Complexity**: M

### Unit 5: `005-inventory`

**Description**: Inventory items and stock updates with no-negative-stock rule via API, web, and mobile.

**Assigned FRs**: FR-10

**Dependencies**:
- Depends on: `001-platform-and-auth`
- Depended by: None

**Estimated Complexity**: M

### Unit 6: `006-income-expenses`

**Description**: General farm income/expense entries and period totals via API, web, and mobile (excluding crop-module expenses).

**Assigned FRs**: FR-11

**Dependencies**:
- Depends on: `001-platform-and-auth`
- Depended by: None

**Estimated Complexity**: M

## Requirement-to-Unit Mapping

- **FR-1** Owner sign-up → `001-platform-and-auth`
- **FR-2** Owner sign-in and sign-out → `001-platform-and-auth`
- **FR-3** Profile and farm settings → `001-platform-and-auth`
- **FR-4** Cow records → `002-cows`
- **FR-5** Cow milk production and feeding → `002-cows`
- **FR-6** Poultry groups and bird counts → `003-poultry`
- **FR-7** Poultry feeding and egg production → `003-poultry`
- **FR-8** Crop names and crop cycles → `004-crops`
- **FR-9** Crop expenses, harvests, and summary → `004-crops`
- **FR-10** Inventory and stock updates → `005-inventory`
- **FR-11** General income and expenses → `006-income-expenses`
- **FR-12** Shared API contract → `001-platform-and-auth` (baseline); each later unit must follow the same contract rules in its API stories
- **FR-13** Owner-only access → `001-platform-and-auth`

## Unit Dependency Graph

```text
001-platform-and-auth
        │
        ├──► 002-cows
        ├──► 003-poultry
        ├──► 004-crops
        ├──► 005-inventory
        └──► 006-income-expenses
```

Domain units after auth are sequenced by product priority (not hard technical deps): cows → poultry → crops → inventory → income/expenses.

## Execution Order

1. `001-platform-and-auth` (API → web → mobile)
2. `002-cows` (API → web → mobile)
3. `003-poultry` (API → web → mobile)
4. `004-crops` (API → web → mobile)
5. `005-inventory` (API → web → mobile)
6. `006-income-expenses` (API → web → mobile)
