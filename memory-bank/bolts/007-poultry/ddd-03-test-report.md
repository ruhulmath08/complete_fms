---
unit: 003-poultry
bolt: 007-poultry
stage: test
status: complete
updated: 2026-11-09T11:33:33Z
---

# Test Report - Poultry (API)

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit (poultry) | 7 | 0 | 0 | Critical paths exercised |
| Integration (poultry) | 2 | 0 | 0 | Critical paths exercised |
| Security (poultry) | 2 | 0 | 0 | - |
| Performance | 0 | 0 | 0 | Not in v1 scope for this bolt |
| **Poultry bolt total** | **11** | **0** | **0** | Critical-path focus |
| Full backend suite | **37** | **0** | **0** | Includes prior auth + cows tests |

**Command**: `pytest` in `backend/` (SQLite in-memory; Postgres not required for suite)

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-poultry-groups | Create/edit/archive poultry group; owner-scoped | ✅ |
| 001-api-poultry-groups | Bird count update persisted via PATCH | ✅ |
| 001-api-poultry-groups | Purchase fields required when purchased; not when born | ✅ |
| 001-api-poultry-groups | Duplicate display names allowed (identity is `id`) | ✅ |
| 002-api-poultry-feeding-and-eggs | Feeding for any type; listable | ✅ |
| 002-api-poultry-feeding-and-eggs | Eggs for layer/duck/local; listable | ✅ |
| 002-api-poultry-feeding-and-eggs | Broiler remains valid without eggs; egg write → `EGGS_NOT_ALLOWED_FOR_TYPE` | ✅ |

## Unit Tests

- Enum parsing (poultry_type/acquired_by) and invalid values
- Purchase field rules (`PURCHASE_FIELDS_INVALID`)
- Egg eligibility + archive write guard
- Name/bird_count/quantity/price/unit/feed_name validation

## Integration Tests

- Group create (purchased + born), duplicate names OK, list meta, bird_count patch
- Archive → excluded from active list; `include_archived`; write on archived → `POULTRY_GROUP_ARCHIVED`
- Feeding add/list on broiler; eggs add/list on layer; broiler eggs → `EGGS_NOT_ALLOWED_FOR_TYPE`; eggs on archived → `POULTRY_GROUP_ARCHIVED`

## Security Tests

- All poultry routes without bearer → `401 UNAUTHORIZED`
- Other owner’s group id → `404 POULTRY_GROUP_NOT_FOUND` (no cross-owner leak); other owner list empty

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical poultry API paths covered. Hard >80% line coverage not enforced for v1 (critical-path policy, same as cows/auth bolts).

## Issues Found

| Issue | Severity | Status |
|-------|----------|--------|
| None | — | — |

## Ready for Operations

- [x] All acceptance criteria met (API stories 001–002)
- [ ] Code coverage > 80% (waived: critical-path policy)
- [x] No critical/high severity issues open
- [x] Performance targets N/A / deferred
- [x] Security tests passing
