---
unit: 001-poultry-actions-api
bolt: 029-poultry-actions-api
stage: implement
status: complete
updated: "2026-11-12T09:55:00Z"
---

# Implementation Walkthrough - 029-poultry-actions-api

## Summary

Extended the poultry API with egg production and poultry feeding PATCH/DELETE (hard-delete), matching cow milk/feeding mutation patterns from bolt `024` without adding poultry feeding `unit_cost`.

## Changes

### Application

- `EggProductionService`: `get`, `update`, `delete`
- `PoultryFeedingService`: `get`, `update`, `delete`
- Archived group blocks update/delete (`POULTRY_GROUP_ARCHIVED`)
- Egg update re-asserts `assert_eggs_allowed`
- Missing rows → `EGG_NOT_FOUND` / `POULTRY_FEEDING_NOT_FOUND`

### Presentation

- `EggProductionUpdateRequest`, `PoultryFeedingUpdateRequest` (partial PATCH)
- `PATCH/DELETE /api/v1/poultry-groups/{group_id}/egg-productions/{egg_id}`
- `PATCH/DELETE /api/v1/poultry-groups/{group_id}/feedings/{feeding_id}`

### Infrastructure

- No schema migration

### Tests

- Integration: update/delete happy path, not-found codes, archived mutate blocked
- Security: unauthenticated PATCH/DELETE egg and feeding paths

## Story mapping

| Story                                 | Delivered                                      |
| ------------------------------------- | ---------------------------------------------- |
| 001-api-egg-update-delete             | Egg PATCH + DELETE                             |
| 002-api-poultry-feeding-update-delete | Poultry feeding PATCH + DELETE                 |

## Verification (local)

```bash
cd backend && . .venv/bin/activate && python -m pytest -q
# 61 passed
```

## Notes

- ADR skipped (no new architectural decision)
- Web/mobile Action UI remains bolts `030` / `031`
