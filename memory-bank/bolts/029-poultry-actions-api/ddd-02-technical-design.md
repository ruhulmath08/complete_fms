---
unit: 001-poultry-actions-api
bolt: 029-poultry-actions-api
stage: design
status: complete
updated: "2026-11-12T09:52:00Z"
---

# Technical Design - 029-poultry-actions-api

## Architecture Pattern

Extend the existing **poultry** FastAPI module with egg/feeding **update** and **hard-delete**, mirroring cow milk/feeding mutation contracts from bolt `024` (without adding poultry feeding `unit_cost`).

**Rationale**: Same layered layout as bolt `007-poultry`; reuses JWT owner deps, error envelope, archive guards, and egg-type eligibility. No new bounded context or persistence schema.

## Layer Structure

```text
┌─────────────────────────────────────┐
│ Presentation                        │  PATCH/DELETE routers + update schemas
├─────────────────────────────────────┤
│ Application                         │  EggProductionService / PoultryFeedingService get+update+delete
├─────────────────────────────────────┤
│ Domain                              │  Existing archive + eggs-allowed + qty/unit validators
├─────────────────────────────────────┤
│ Infrastructure                      │  Existing SQLAlchemy models (no migration)
└─────────────────────────────────────┘
```

### Backend touchpoints (this bolt)

```text
backend/app/modules/poultry/
├── application/services.py     # get / update / delete on egg + feeding services
├── presentation/schemas.py     # EggProductionUpdateRequest, PoultryFeedingUpdateRequest
└── presentation/routers.py     # PATCH/DELETE nested routes

backend/tests/
├── integration/test_poultry_api.py   # happy path + archive + not found
└── security/test_poultry_authz.py    # unauthenticated / cross-owner
```

Mount remains under `/api/v1/poultry-groups`.

## Construction Decisions

| Decision            | Choice                                                                 | Notes                                                                 |
| ------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Delete semantics    | **Hard-delete**                                                        | Row removed; no soft flag                                             |
| Update semantics    | Partial PATCH via `model_fields_set`                                   | Same pattern as cow milk/feeding                                      |
| Archived group      | Block create/**update**/**delete** of egg/feeding                      | `409 POULTRY_GROUP_ARCHIVED`                                          |
| Egg eligibility     | Re-assert `assert_eggs_allowed` on egg update                          | Broiler / ineligible → `422 EGGS_NOT_ALLOWED_FOR_TYPE`                |
| Cross-owner / miss  | `404`                                                                  | `EGG_NOT_FOUND` / `POULTRY_FEEDING_NOT_FOUND` (or group not found)    |
| Poultry `unit_cost` | **Out of scope**                                                       | Feeding schema unchanged from create/list                             |
| Schema migration    | **None**                                                               | Existing `egg_productions` / `poultry_feedings` tables                |
| ADR needed?         | **No** — extends existing poultry + cow mutation patterns; Stage 3 skip |                                                                       |

## API Design

Base: `/api/v1` · Auth: Bearer access · JSON snake_case · Errors `{code,message,details?}`

### Eggs (extend)

| Endpoint                                                          | Method | Auth  | Request                 | Response              |
| ----------------------------------------------------------------- | ------ | ----- | ----------------------- | --------------------- |
| `/api/v1/poultry-groups/{group_id}/egg-productions/{egg_id}`      | PATCH  | Owner | EggProductionUpdate     | EggProduction         |
| `/api/v1/poultry-groups/{group_id}/egg-productions/{egg_id}`      | DELETE | Owner | —                       | `204` No Content      |

### Feeding (extend)

| Endpoint                                                     | Method | Auth  | Request                | Response              |
| ------------------------------------------------------------ | ------ | ----- | ---------------------- | --------------------- |
| `/api/v1/poultry-groups/{group_id}/feedings/{feeding_id}`    | PATCH  | Owner | PoultryFeedingUpdate   | PoultryFeeding        |
| `/api/v1/poultry-groups/{group_id}/feedings/{feeding_id}`    | DELETE | Owner | —                      | `204` No Content      |

Existing POST/GET list endpoints unchanged.

### Schemas (deltas)

**EggProductionUpdate**: optional `produced_at`, `quantity`, `unit`, `price_per_unit`, `note`

**PoultryFeedingUpdate**: optional `fed_at`, `feed_name`, `quantity`, `unit`, `note`

**EggProduction** / **PoultryFeeding** responses: unchanged field sets from create/list.

## Data Persistence

| Table              | Change | Notes                                      |
| ------------------ | ------ | ------------------------------------------ |
| `egg_productions`  | None   | Hard-delete via SQLAlchemy `session.delete` |
| `poultry_feedings` | None   | Same                                       |

No Alembic revision.

## Security Design

| Concern         | Approach                                                              |
| --------------- | --------------------------------------------------------------------- |
| Authentication  | Existing JWT `get_current_owner`                                      |
| Authorization   | Filter by `owner_id` + `poultry_group_id`; wrong id → `404`           |
| Archived writes | Reject egg/feeding PATCH/DELETE with `409 POULTRY_GROUP_ARCHIVED`     |
| Validation      | Reuse poultry domain validators; `422 VALIDATION_ERROR` / egg type    |

## NFR Implementation

| Requirement    | Design Approach                                              |
| -------------- | ------------------------------------------------------------ |
| Compatibility  | Additive routes only; create/list contracts unchanged        |
| Contract-first | OpenAPI via FastAPI routes before web `030` / mobile `031`   |
| Performance    | Single-row load by PK + owner/group filters; no list change  |

## Error Handling

| Error Type                          | HTTP | Code                                      |
| ----------------------------------- | ---- | ----------------------------------------- |
| Validation                          | 422  | `VALIDATION_ERROR`                        |
| Eggs not allowed for type           | 422  | `EGGS_NOT_ALLOWED_FOR_TYPE`               |
| Group archived (write)              | 409  | `POULTRY_GROUP_ARCHIVED`                  |
| Egg not found / not owned / wrong group | 404 | `EGG_NOT_FOUND`                        |
| Feeding not found / not owned / wrong group | 404 | `POULTRY_FEEDING_NOT_FOUND`        |
| Group not found / not owned         | 404  | `POULTRY_GROUP_NOT_FOUND`                 |
| Unauthorized                        | 401  | `UNAUTHORIZED`                            |

## Application Use Cases

| Story                                  | Use cases                                      |
| -------------------------------------- | ---------------------------------------------- |
| 001-api-egg-update-delete              | `UpdateEggProduction`, `DeleteEggProduction`   |
| 002-api-poultry-feeding-update-delete  | `UpdatePoultryFeeding`, `DeletePoultryFeeding` |

Implementation sketch (mirror cows):

1. Resolve group by `owner_id` + `group_id` → not found / archived guards
2. Resolve child by `owner_id` + `group_id` + child id → not found
3. Update: apply only fields in `fields_set`; re-run validators; commit
4. Delete: `session.delete(row)`; commit; return 204

## External Dependencies

| Service    | Purpose                | Integration         |
| ---------- | ---------------------- | ------------------- |
| PostgreSQL | Persist / hard-delete  | Existing SQLAlchemy |
| Auth       | Owner identity         | `get_current_owner` |

## Testing Plan (preview for Stage 5)

- API: PATCH/DELETE egg happy path; list no longer contains deleted row
- API: PATCH/DELETE feeding happy path
- API: archived group → `409 POULTRY_GROUP_ARCHIVED` on egg/feeding mutate
- API: wrong owner / wrong group / missing id → `404`
- API: unauthenticated → `401`
- API: egg update on broiler (if reachable) → `EGGS_NOT_ALLOWED_FOR_TYPE`
- Security suite: include new PATCH/DELETE paths in poultry authz matrix

## Out of Scope

- Soft-delete
- Poultry feeding `unit_cost` / totals
- Web/mobile UI (bolts `030`, `031`)
- Changing create/list defaults or group CRUD

## ADR Assessment (preview)

No new architectural pattern or tech choice. **Stage 3 ADR analysis: skip** unless Implement discovers a standards conflict.
