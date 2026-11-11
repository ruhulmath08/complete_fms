---
intent: 002-design-system-refresh
phase: inception
status: units-decomposed
updated: 2026-11-11T18:01:56Z
---

# Design System Refresh - Unit Decomposition

## Units Overview

This intent decomposes by **layer** (API → web → mobile), matching `project.yaml` unit structure. API changes land first where clients depend on them; web shell/tokens can proceed in parallel with API; cow tables/forms and mobile cow refresh wait on API.

### Unit 1: `001-design-api`

**Description**: Backend contract and behavior for auto-generated cow tag numbers, cow image association/storage, and paginated milk/feeding lists (page size 10).

**Assigned FRs**: FR-4, FR-8

**Dependencies**:

- Depends on: None (extends existing cows/platform APIs from intent 001)
- Depended by: `002-design-web`, `003-design-mobile`

**Unit Type**: backend  
**Default Bolt Type**: ddd-construction-bolt  
**Estimated Complexity**: M

### Unit 2: `002-design-web`

**Description**: React web visual/UX refresh — left sidebar shell (header/footer, notification + profile chrome), design tokens, add-cow image/labels, Bootstrap milk/feeding tables, prefer tables for tabular data.

**Assigned FRs**: FR-1, FR-3, FR-5, FR-6, FR-7, FR-9

**Dependencies**:

- Depends on: `001-design-api` (for cow image, auto tag, milk/feeding pagination)
- Depended by: None

**Unit Type**: web  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: M

### Unit 3: `003-design-mobile`

**Description**: Flutter mobile visual/UX refresh — card list layouts, mirrored design tokens, cow create image/Weight (kg), consume auto tag and cow image from API.

**Assigned FRs**: FR-2

**Dependencies**:

- Depends on: `001-design-api` (for auto tag and cow image on create/detail)
- Depended by: None

**Unit Type**: mobile  
**Default Bolt Type**: simple-construction-bolt  
**Estimated Complexity**: M

**Note**: Mobile cow image / Weight (kg) / auto-tag consumption align with FR-3 and FR-4 UX but are delivered in this unit so each FR maps to a single primary owner unit (FR-3/FR-9 → web; FR-4 → API).

## Requirement-to-Unit Mapping

- **FR-1** Web app shell → `002-design-web`
- **FR-2** Mobile list cards → `003-design-mobile`
- **FR-3** Add cow image and Weight (kg) → `002-design-web` (mobile parity in `003-design-mobile` stories)
- **FR-4** Cow tag auto-generation → `001-design-api`
- **FR-5** Milk Bootstrap table + pagination → `002-design-web`
- **FR-6** Feeding paginated table → `002-design-web`
- **FR-7** Prefer tables on web → `002-design-web`
- **FR-8** API contract updates for UI → `001-design-api`
- **FR-9** Shared design tokens/components → `002-design-web` (mobile mirrors in `003-design-mobile`)

## Unit Dependency Graph

```text
001-design-api
      │
      ├──► 002-design-web
      └──► 003-design-mobile
```

Web shell/tokens and mobile cards/tokens may start in parallel with API; cow form/tables and mobile cow refresh require API completion.

## Execution Order

1. `001-design-api`
2. `002-design-web` (shell/tokens early; cow/tables after API)
3. `003-design-mobile` (cards/tokens early; cow refresh after API)
