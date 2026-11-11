---
unit: 001-design-api
bolt: 019-design-api
stage: test
status: complete
updated: 2026-11-11T18:19:36Z
---

# Test Report - Design API (Cows contract extensions)

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit (cows domain) | 9 | 0 | 0 | Critical paths exercised |
| Integration (cows API) | 3 | 0 | 0 | Critical paths exercised |
| Security (cows authz) | 2 | 0 | 0 | - |
| Performance | 0 | 0 | 0 | Not in v1 scope for this bolt |
| **Cows design-api bolt total** | **14** | **0** | **0** | Critical-path focus |
| Full backend suite | **59** | **0** | **0** | Includes prior auth/cows/poultry/crops/inventory/ledger |

**Command**: `pytest tests/unit/test_cow_domain_rules.py tests/integration/test_cows_api.py tests/security/test_cows_authz.py` in `backend/` (SQLite in-memory)

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-auto-tag-number | Create without client tag; tag = name+breed+6 digits | ✅ |
| 001-api-auto-tag-number | Name/breed required; tag stable after rename | ✅ |
| 001-api-auto-tag-number | Unique active tag generation | ✅ (generator + uniqueness check) |
| 002-api-cow-image | Upload/get/delete image; `image_url` on cow | ✅ |
| 002-api-cow-image | Unauthenticated / other-owner denied | ✅ |
| 003-api-milk-feeding-pagination | Default limit 10; second page for milk/feeding | ✅ |
| 003-api-milk-feeding-pagination | Existing milk/feeding eligibility rules still hold | ✅ |

## Unit Tests

- Enum / purchase / milk / archive guards (existing)
- `validate_required_name_breed` and `build_generated_tag` format/length rules

## Integration Tests

- Cow CRUD + archive with generated tags
- Cow image PUT/GET/DELETE lifecycle
- Milk (12 entries) and feeding (11 entries) default page size 10 + offset page

## Security Tests

- All cows routes (including image) without bearer → `401 UNAUTHORIZED`
- Other owner’s cow / image → `404 COW_NOT_FOUND` or `COW_IMAGE_NOT_FOUND`

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical design-api paths covered (tag gen, image, paging). Hard >80% line coverage not enforced for v1 (critical-path policy, same as prior bolts).

## Issues Found

| Issue | Severity | Status |
|-------|----------|--------|
| Web/mobile clients still send `tag_number` on create | Medium | Open — bolts 021 / 023 |
| Local Postgres needs `alembic upgrade head` for `image_path` | Low | Ops note |

## Ready for Operations

- [x] All acceptance criteria met (API stories 001–003)
- [ ] Code coverage > 80% (waived: critical-path policy)
- [x] No critical/high severity issues open in API scope
- [x] Performance targets N/A / deferred
- [x] Security tests passing
