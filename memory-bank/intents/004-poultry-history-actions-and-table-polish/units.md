---
intent: 004-poultry-history-actions-and-table-polish
phase: inception
status: units-decomposed
updated: "2026-11-12T09:47:02Z"
---

# Poultry History Actions and Table Polish - Unit Decomposition

## Units Overview

Layered API → web → mobile. API mutations first; web/mobile Action and table polish depend on them (web polish for `#`/`No.` and colors can finish after poultry Action wiring).

### Unit 1: `001-poultry-actions-api`

**Description**: FastAPI PATCH/DELETE for poultry egg productions and poultry feedings with owner/archive/authz parity to cow milk/feeding.

**Assigned FRs**: FR-1, FR-2 (supports FR-3–FR-5, NFR-1, NFR-2, NFR-4)

**Dependencies**:

- Depends on: None (extends existing poultry module)
- Depended by: `002-poultry-actions-web`, `003-poultry-actions-mobile`

**Unit Type**: backend  
**Default Bolt Type**: ddd-construction-bolt  
**Estimated Complexity**: S

### Unit 2: `002-poultry-actions-web`

**Description**: React poultry detail Action columns; history `#` → **No.** across web history tables; Edit primary / Delete danger on Action icons (including cow milk/feeding alignment).

**Assigned FRs**: FR-3, FR-4, FR-6, FR-7, FR-8 (web)

**Dependencies**:

- Depends on: `001-poultry-actions-api` (for Action wiring; polish may start earlier)
- Depended by: None

**Unit Type**: web  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: S

### Unit 3: `003-poultry-actions-mobile`

**Description**: Flutter poultry egg/feeding Edit/Delete with confirm; history **No.** labeling and primary/danger Action colors; preserve add flows.

**Assigned FRs**: FR-5, FR-6, FR-7, FR-8 (mobile), NFR-3

**Dependencies**:

- Depends on: `001-poultry-actions-api`
- Depended by: None

**Unit Type**: mobile  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: S

## Requirement-to-Unit Mapping

- **FR-1** Egg PATCH/DELETE API → `001-poultry-actions-api`
- **FR-2** Feeding PATCH/DELETE API → `001-poultry-actions-api`
- **FR-3** Web egg Action → `002-poultry-actions-web`
- **FR-4** Web feeding Action → `002-poultry-actions-web`
- **FR-5** Mobile egg/feeding Action → `003-poultry-actions-mobile`
- **FR-6** `#` → `No.` all history tables → `002-poultry-actions-web` + `003-poultry-actions-mobile`
- **FR-7** Edit primary / Delete danger → `002-poultry-actions-web` + `003-poultry-actions-mobile`
- **FR-8** Add path remains → web + mobile units

## Unit Dependency Graph

```text
001-poultry-actions-api
      │
      ├──► 002-poultry-actions-web
      └──► 003-poultry-actions-mobile
```
