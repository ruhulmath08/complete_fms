---
intent: 003-update-api-web-and-mobile-design
phase: inception
status: units-decomposed
updated: "2026-11-12T07:34:21Z"
---

# Update API, Web, and Mobile Design - Unit Decomposition

## Units Overview

Decomposed by **layer** (API → web → mobile), matching `project.yaml`. API lands first where clients depend on totals and row mutations; web shell/tokens/layout can start in parallel; table Action/totals and mobile cow/history refresh wait on API.

### Unit 1: `001-design-api`

**Description**: Backend contract updates for row totals (especially Feeding), update/delete for tabular sub-records (milk/feeding minimum), and pagination metadata for entity/history lists at page size 10.

**Assigned FRs**: FR-10

**Dependencies**:

- Depends on: None (extends existing APIs from intents 001/002)
- Depended by: `002-design-web`, `003-design-mobile`

**Unit Type**: backend  
**Default Bolt Type**: ddd-construction-bolt  
**Estimated Complexity**: M

### Unit 2: `002-design-web`

**Description**: Production-ready React web redesign — visual tokens, shell polish, universal paginated tables, empty/loading/error, row Total + Action columns, cow detail layout, remove Back links, refresh Edit/Archive, forms/a11y, developer docs.

**Assigned FRs**: FR-1, FR-2, FR-4, FR-5, FR-6, FR-8, FR-9, FR-11, FR-12, FR-13, FR-14, FR-15, FR-16

**Dependencies**:

- Depends on: `001-design-api` (for totals, update/delete, list pagination)
- Depended by: None

**Unit Type**: web  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: L

### Unit 3: `003-design-mobile`

**Description**: Production-ready Flutter mobile redesign — navigation chrome, mirrored tokens/states, detail/history visual parity with pagination, totals/actions/cow layout parity, forms/a11y.

**Assigned FRs**: FR-3, FR-7

**Dependencies**:

- Depends on: `001-design-api` (for totals, update/delete, pagination)
- Depended by: None

**Unit Type**: mobile  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: M

**Note**: Mobile delivers parity for FR-1, FR-5, FR-6, FR-8, FR-9, FR-12, FR-13, FR-14, FR-15 (where back links exist) so each FR keeps a single primary owner unit (web owns shared UI FRs; mobile owns FR-3/FR-7).

## Requirement-to-Unit Mapping

- **FR-1** Production-ready visual system → `002-design-web` (mobile mirrors in `003-design-mobile`)
- **FR-2** Web shell polish → `002-design-web`
- **FR-3** Mobile navigation chrome → `003-design-mobile`
- **FR-4** Universal data tables → `002-design-web`
- **FR-5** Empty/loading/error → `002-design-web` (mobile mirrors)
- **FR-6** Pagination parity → `002-design-web` (mobile mirrors)
- **FR-7** Mobile detail/history parity → `003-design-mobile`
- **FR-8** Form/filter consistency → `002-design-web` (mobile mirrors)
- **FR-9** Practical a11y → `002-design-web` (mobile mirrors)
- **FR-10** API updates for redesign → `001-design-api`
- **FR-11** Developer docs → `002-design-web`
- **FR-12** Row Total columns → `002-design-web` (API support via FR-10; mobile mirrors)
- **FR-13** Action Edit/Delete → `002-design-web` (API via FR-10; mobile mirrors)
- **FR-14** Cow image left / info right → `002-design-web` (mobile mirrors)
- **FR-15** Remove Back links → `002-design-web` (mobile if present)
- **FR-16** Refresh Edit/Archive → `002-design-web`

## Unit Dependency Graph

```text
001-design-api
      │
      ├──► 002-design-web
      └──► 003-design-mobile
```

Web shell/tokens/layout and mobile nav/tokens may start in parallel with API; table Action/totals and mobile history mutations require API completion.

## Execution Order

1. `001-design-api`
2. `002-design-web` (shell/tokens/layout early; tables/actions/cow chrome after API)
3. `003-design-mobile` (nav/tokens early; history/actions after API)
