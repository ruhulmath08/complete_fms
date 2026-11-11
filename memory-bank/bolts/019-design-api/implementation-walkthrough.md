---
unit: 001-design-api
bolt: 019-design-api
stage: implement
status: complete
updated: 2026-11-11T18:14:48Z
---

# Implementation Walkthrough - 019-design-api

## Summary

Extended the cows API for design-system refresh: server-generated tag numbers, optional cow images, and milk/feeding list default page size 10.

## Changes

### Domain
- `validate_required_name_breed`, `build_generated_tag` in `domain/rules.py`
- Tag = name + breed + 6 digits; max combined length respects `tag_number` String(64)

### Application
- `CowService.create` generates unique tag (up to 10 retries); no client tag
- `CowService.update` no longer accepts `tag_number` (tag stable after create)
- `attach_image` / `clear_image` / `resolve_image_path`
- Milk/feeding `_clamp_paging(..., default_limit=10)`

### Infrastructure
- `cows.image_path` column + Alembic `20261111_0007`
- `CowImageStore` under `uploads/cow_images/{owner_id}/{cow_id}/`

### Presentation
- `CowCreateRequest`: required `name`/`breed`; no `tag_number`
- `CowResponse.image_url`
- `PUT/DELETE/GET /api/v1/cows/{id}/image`
- Milk/feeding GET default `limit=10`

## Story mapping

| Story | Delivered |
|-------|-----------|
| 001-api-auto-tag-number | Yes |
| 002-api-cow-image | Yes |
| 003-api-milk-feeding-pagination | Yes |

## Tests run

```text
pytest tests/unit/test_cow_domain_rules.py \
       tests/integration/test_cows_api.py \
       tests/security/test_cows_authz.py
→ 14 passed
```

## Client follow-ups (later bolts)

- Web `021` / mobile `023` must stop sending `tag_number` on create and wire image upload + page size 10.
