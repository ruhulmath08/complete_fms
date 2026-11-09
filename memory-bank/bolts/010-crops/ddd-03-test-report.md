---
unit: 004-crops
bolt: 010-crops
stage: test
status: complete
updated: 2026-11-09T12:12:00Z
---

# Test Report - Crops (API)

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit (crops) | 3 | 0 | 0 | Critical paths exercised |
| Integration (crops) | 2 | 0 | 0 | Critical paths exercised |
| Security (crops) | 2 | 0 | 0 | - |
| Performance | 0 | 0 | 0 | Not in v1 scope for this bolt |
| **Crops bolt total** | **7** | **0** | **0** | Critical-path focus |
| Full backend suite | **44** | **0** | **0** | Includes prior auth/cows/poultry |

**Command**: `pytest` in `backend/` (SQLite in-memory; Postgres not required for suite)

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-crop-names-and-cycles | CRUD/archive crop names; owner-scoped | ✅ |
| 001-api-crop-names-and-cycles | Cycle requires catalog id; archived name rejected | ✅ |
| 001-api-crop-names-and-cycles | Cycle CRUD/archive; active name uniqueness + reuse after archive | ✅ |
| 002-api-crop-expenses-harvests-summary | Categorized expenses add/list | ✅ |
| 002-api-crop-expenses-harvests-summary | Harvests with optional sale_amount | ✅ |
| 002-api-crop-expenses-harvests-summary | Summary totals match entered records | ✅ |

## Unit Tests

- Expense category parsing
- Name/area/amount/quantity/unit validation
- Archive guards (`CROP_NAME_ARCHIVED` 409 vs 422; `CROP_CYCLE_ARCHIVED`)

## Integration Tests

- Name create, duplicate active → `CROP_NAME_ALREADY_EXISTS`, archive + name reuse
- Cycle create; cycle with archived name → `CROP_NAME_ARCHIVED`; cycle archive write block
- Expenses + harvests + summary math (null sale ignored / coalesce 0); expense on archived cycle blocked

## Security Tests

- All crops routes without bearer → `401 UNAUTHORIZED`
- Other owner’s name/cycle → `404 CROP_NAME_NOT_FOUND` / `CROP_CYCLE_NOT_FOUND`; lists empty

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical crops API paths covered. Hard >80% line coverage not enforced for v1 (critical-path policy).

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
