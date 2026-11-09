---
unit: 002-cows
bolt: 004-cows
stage: test
status: complete
updated: 2026-11-09T11:02:07Z
---

# Test Report - Cows (API)

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit (cows) | 8 | 0 | 0 | Critical paths exercised |
| Integration (cows) | 2 | 0 | 0 | Critical paths exercised |
| Security (cows) | 2 | 0 | 0 | - |
| Performance | 0 | 0 | 0 | Not in v1 scope for this bolt |
| **Cows bolt total** | **12** | **0** | **0** | Critical-path focus |
| Full backend suite | **26** | **0** | **0** | Includes prior auth tests |

**Command**: `pytest` in `backend/` (SQLite in-memory; Postgres not required for suite)

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-cow-records | Create/edit cow with valid fields; owner-scoped | ✅ |
| 001-api-cow-records | Purchase fields required when purchased; not when born | ✅ |
| 001-api-cow-records | Archive excludes from default active list; GET archived OK | ✅ |
| 002-api-cow-milk-and-feeding | Milk entries for milk/both purpose cows | ✅ |
| 002-api-cow-milk-and-feeding | Meat-only cow valid without milk; milk write rejected | ✅ |
| 002-api-cow-milk-and-feeding | Feeding entries for any cow; list by cow | ✅ |

## Unit Tests

- Enum parsing (purpose/gender/acquired_by) and invalid values
- Purchase field rules (`PURCHASE_FIELDS_INVALID`)
- Milk eligibility + archive write guard
- Tag/quantity/price/unit/feed_name validation

## Integration Tests

- Cow create (purchased + born), list paging meta, patch, duplicate active tag → `TAG_ALREADY_EXISTS`
- Archive → excluded from active list; `include_archived`; tag reuse after archive; write on archived → `COW_ARCHIVED`
- Milk add/list; meat milk → `MILK_NOT_ALLOWED_FOR_PURPOSE`; feeding add/list; milk on archived → `COW_ARCHIVED`

## Security Tests

- All cows routes without bearer → `401 UNAUTHORIZED`
- Other owner’s cow id → `404 COW_NOT_FOUND` (no cross-owner leak); other owner list empty

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical cows API paths covered. Hard >80% line coverage not enforced for v1 (critical-path policy, same as auth bolt). SQLite uses `sqlite_where` on the active-tag unique index to mirror ADR-006 in tests.

## Issues Found

| Issue | Severity | Status |
|-------|----------|--------|
| Partial unique index was Postgres-only; SQLite tests would enforce forever-unique tags | Medium | Fixed (`sqlite_where=is_archived = 0`) |

## Ready for Operations

- [x] All acceptance criteria met (API stories 001–002)
- [ ] Code coverage > 80% (waived: critical-path policy)
- [x] No critical/high severity issues open
- [x] Performance targets N/A / deferred
- [x] Security tests passing
