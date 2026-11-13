---
intent: 005-resolve-operations-and-calculations-issue
phase: inception
status: units-decomposed
updated: '2026-11-13T07:00:00Z'
---

# Resolve Operations and Calculations Issue - Unit Decomposition

## Units Overview

Layered API → web → mobile. API mutations and aggregates first; web/mobile Action, tables, graphs, and Dashboard landing depend on them.

### Unit 1: `001-ops-calc-api`

**Description**: FastAPI crop expense/harvest PATCH/DELETE; fertilizer-category stock list (mutations if required); ledger range series for graphs; dashboard aggregates; farm-local-TZ future-date rejection.

**Assigned FRs**: FR-1, FR-2, FR-3, FR-4, FR-6, FR-7, FR-8 (API)

**Dependencies**:

- Depends on: None (extends existing crops/inventory/ledger/cows/poultry modules)
- Depended by: `002-ops-calc-web`, `003-ops-calc-mobile`

**Unit Type**: backend  
**Default Bolt Type**: ddd-construction-bolt  
**Estimated Complexity**: M

### Unit 2: `002-ops-calc-web`

**Description**: React crop Expenses/Harvests Action; fertilizer-category stock table; ledger numeric totals + graph; Dashboard page as post-login landing with period controls.

**Assigned FRs**: FR-1–FR-7 (web)

**Dependencies**:

- Depends on: `001-ops-calc-api`
- Depended by: None

**Unit Type**: web  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: M

### Unit 3: `003-ops-calc-mobile`

**Description**: Flutter crop Expenses/Harvests Action; fertilizer-category stock table; ledger numeric totals + graph; Dashboard page as post-login landing with period controls; EN/BN strings.

**Assigned FRs**: FR-1–FR-7 (mobile), NFR-4

**Dependencies**:

- Depends on: `001-ops-calc-api`
- Depended by: None

**Unit Type**: mobile  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: M

## Requirement-to-Unit Mapping

- **FR-1** Crop expenses Action → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-2** Crop harvests Action → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-3** Fertilizer-category stock table → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-4** Ledger numeric + graph → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-5** Dashboard landing → `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-6** Dashboard graphs → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-7** Period / no future dates → `001-ops-calc-api` + `002-ops-calc-web` + `003-ops-calc-mobile`
- **FR-8** API only as needed → `001-ops-calc-api`

## Unit Dependency Graph

```text
001-ops-calc-api
      │
      ├──► 002-ops-calc-web
      └──► 003-ops-calc-mobile
```
