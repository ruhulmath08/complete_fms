---
unit: 001-design-api
intent: 002-design-system-refresh
phase: inception
status: complete
created: '2026-11-11T18:01:56Z'
updated: '2026-11-11T18:01:56Z'
unit_type: backend
default_bolt_type: ddd-construction-bolt
---

# Unit Brief: Design API

## Purpose

Extend the FastAPI cows (and related list) contracts so the refreshed web/mobile UIs can auto-generate tag numbers, attach cow images, and page milk/feeding history at 10 rows per page.

## Scope

### In Scope

- Auto-generate `tag_number` as name + breed + 6 random digits on cow create; uniqueness for the owner
- Cow image upload/association using existing local-disk upload patterns where practical
- Milk and feeding list pagination with default page size 10 (`items` + `meta`)
- OpenAPI/contract updates for clients

### Out of Scope

- Web/mobile UI implementation
- Notification backend
- Unrelated domain API rewrites

---

## Assigned Requirements

| FR   | Requirement                         | Priority |
| ---- | ----------------------------------- | -------- |
| FR-4 | Cow tag number auto-generation      | Must     |
| FR-8 | API contract updates for UI support | Must     |

---

## Domain Concepts

### Key Entities

| Entity         | Description              | Attributes                                                                   |
| -------------- | ------------------------ | ---------------------------------------------------------------------------- |
| Cow            | Existing cow aggregate   | tag_number (generated), optional image path/URL, weight as kg-oriented value |
| MilkProduction | Existing milk entries    | list via pagination                                                          |
| CowFeeding     | Existing feeding entries | list via pagination                                                          |

### Key Operations

| Operation    | Description                  | Inputs                                        | Outputs                  |
| ------------ | ---------------------------- | --------------------------------------------- | ------------------------ |
| Create cow   | Generate tag; optional image | name, breed, other cow fields, optional image | Cow JSON with tag_number |
| List milk    | Paginated history            | cow id, limit/offset or page                  | items + meta             |
| List feeding | Paginated history            | cow id, limit/offset or page                  | items + meta             |

---

## Story Summary

| Metric        | Count |
| ------------- | ----- |
| Total Stories | 3     |
| Must Have     | 3     |
| Should Have   | 0     |
| Could Have    | 0     |

### Stories

| Story ID                        | Title                       | Priority | Status  |
| ------------------------------- | --------------------------- | -------- | ------- |
| 001-api-auto-tag-number         | API auto tag number         | Must     | Planned |
| 002-api-cow-image               | API cow image               | Must     | Planned |
| 003-api-milk-feeding-pagination | API milk/feeding pagination | Must     | Planned |

---

## Dependencies

### Depends On

| Unit                       | Reason                |
| -------------------------- | --------------------- |
| (intent 001 cows/platform) | Extends existing APIs |

### Depended By

| Unit              | Reason                                 |
| ----------------- | -------------------------------------- |
| 002-design-web    | Needs tag, image, pagination contracts |
| 003-design-mobile | Needs tag and image contracts          |

---

## Technical Constraints

- Follow existing `/api/v1` error and auth patterns
- Local disk uploads outside Git (same approach as profile images)
- Default page size 10 for milk/feeding lists

## Success Criteria

- [ ] Tag generated as name+breed+6 digits; unique per owner
- [ ] Cow image associable and authorized
- [ ] Milk/feeding lists support page size 10 with meta
- [ ] Contract documented for web and mobile
