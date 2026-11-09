---
unit: 006-income-expenses
bolt: 016-income-expenses
stage: test
status: complete
updated: 2026-11-09T13:21:48Z
---

# Test Report - Income and Expenses (API)

## Test Summary

| Category                       | Passed | Failed | Skipped | Coverage                                         |
| ------------------------------ | ------ | ------ | ------- | ------------------------------------------------ |
| Unit (income-expenses)         | 2      | 0      | 0       | Critical paths exercised                         |
| Integration (income-expenses)  | 2      | 0      | 0       | Critical paths exercised                         |
| Security (income-expenses)     | 2      | 0      | 0       | -                                                |
| Performance                    | 0      | 0      | 0       | Not in v1 scope for this bolt                    |
| **Income-expenses bolt total** | **6**  | **0**  | **0**   | Critical-path focus                              |
| Full backend suite             | **57** | **0**  | **0**   | Includes prior auth/cows/poultry/crops/inventory |

**Command**: `pytest` in `backend/` (SQLite in-memory; Postgres not required for suite)

## Acceptance Criteria Validation

| Story                       | Criteria                                               | Status |
| --------------------------- | ------------------------------------------------------ | ------ |
| 001-api-income-and-expenses | Entry CRUD + archive; owner-scoped                     | ✅     |
| 001-api-income-and-expenses | Period totals income/expenses/net for date range       | ✅     |
| 001-api-income-and-expenses | Archived excluded from totals; crop expenses not mixed | ✅     |
| 001-api-income-and-expenses | `total_price` equals `amount`; archived write block    | ✅     |

## Unit Tests

- Entry type / category parsing
- Positive amount; date range validation; net; archive guard

## Integration Tests

- Create/update/archive; `total_price` mirrors `amount`
- Period totals for range; archived and out-of-range excluded; list date filters; invalid range → 422

## Security Tests

- Ledger routes without bearer → `401 UNAUTHORIZED`
- Other owner’s entry → `404 LEDGER_ENTRY_NOT_FOUND`

## Performance Tests

| Metric              | Target          | Actual       | Status      |
| ------------------- | --------------- | ------------ | ----------- |
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput          | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical ledger API paths covered. Hard >80% line coverage not enforced for v1 (critical-path policy).

## Issues Found

| Issue | Severity | Status |
| ----- | -------- | ------ |
| None  | —        | —      |

## Ready for Operations

- [x] All acceptance criteria met (API story 001)
- [ ] Code coverage > 80% (waived: critical-path policy)
- [x] No critical/high severity issues open
- [x] Performance targets N/A / deferred
- [x] Security tests passing
