---
unit: 005-inventory
bolt: 013-inventory
stage: test
status: complete
updated: 2026-11-09T13:01:00Z
---

# Test Report - Inventory (API)

## Test Summary

| Category                 | Passed | Failed | Skipped | Coverage                               |
| ------------------------ | ------ | ------ | ------- | -------------------------------------- |
| Unit (inventory)         | 3      | 0      | 0       | Critical paths exercised               |
| Integration (inventory)  | 2      | 0      | 0       | Critical paths exercised               |
| Security (inventory)     | 2      | 0      | 0       | -                                      |
| Performance              | 0      | 0      | 0       | Not in v1 scope for this bolt          |
| **Inventory bolt total** | **7**  | **0**  | **0**   | Critical-path focus                    |
| Full backend suite       | **51** | **0**  | **0**   | Includes prior auth/cows/poultry/crops |

**Command**: `pytest` in `backend/` (SQLite in-memory; Postgres not required for suite)

## Acceptance Criteria Validation

| Story                       | Criteria                                     | Status |
| --------------------------- | -------------------------------------------- | ------ |
| 001-api-inventory-and-stock | Item CRUD + archive; owner-scoped            | ✅     |
| 001-api-inventory-and-stock | Stock add/use adjusts displayed quantity     | ✅     |
| 001-api-inventory-and-stock | Use below zero → `INSUFFICIENT_STOCK`        | ✅     |
| 001-api-inventory-and-stock | Computed `total_price`; archived write block | ✅     |

## Unit Tests

- Category / change-type parsing
- Quantity/price validation; quantized total price
- Stock apply add/use; insufficient stock details; archive guard

## Integration Tests

- Create item with initial quantity + `total_price`; PATCH price/name without changing quantity
- Archive blocks item update and stock add
- Stock add/use adjusts quantity; over-use → 409; stock list total

## Security Tests

- Inventory routes without bearer → `401 UNAUTHORIZED`
- Other owner’s item → `404 INVENTORY_ITEM_NOT_FOUND`; lists empty

## Performance Tests

| Metric              | Target          | Actual       | Status      |
| ------------------- | --------------- | ------------ | ----------- |
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput          | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical inventory API paths covered. Hard >80% line coverage not enforced for v1 (critical-path policy).

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
