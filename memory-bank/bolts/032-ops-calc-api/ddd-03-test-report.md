---
unit: 001-ops-calc-api
bolt: 032-ops-calc-api
stage: test
status: complete
updated: '2026-11-13T07:30:00Z'
---

# Test Report - 032-ops-calc-api

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Integration (ops-calc focus) | 9 | 0 | 0 | Crops mutate, fertilizer list, series, dashboard |
| Security (extended routes) | — | 0 | 0 | Unauth crop PATCH/DELETE, stock list, series, dashboard |
| Performance | 0 | 0 | 0 | Not in scope |
| Full backend suite | **64** | **0** | **0** | Includes prior modules |

**Commands** (in `backend/` with venv):

```bash
python -m pytest tests/integration/test_crops_api.py \
  tests/integration/test_inventory_api.py \
  tests/integration/test_dashboard_api.py \
  tests/integration/test_income_expenses_api.py -q
# 9 passed

python -m pytest -q
# 64 passed
```

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-crop-expense-harvest-update-delete | PATCH updates expense/harvest fields | ✅ |
| 001-api-crop-expense-harvest-update-delete | DELETE returns 204; row gone | ✅ |
| 001-api-crop-expense-harvest-update-delete | Archived cycle / missing id rejected | ✅ |
| 001-api-crop-expense-harvest-update-delete | Unauthenticated → 401 | ✅ |
| 002-api-fertilizer-stock-list | Category filter returns only fertilizer updates + item fields | ✅ |
| 002-api-fertilizer-stock-list | Unauthenticated list → 401 | ✅ |
| 003-api-ledger-range-series | Series zero-fills missing buckets | ✅ |
| 003-api-ledger-range-series | Totals/series reject future `to` | ✅ |
| 004-api-dashboard-aggregates | Aggregates include all six series keys + timezone | ✅ |
| 004-api-dashboard-aggregates | Future `to` → `FUTURE_DATE_NOT_ALLOWED` | ✅ |

## Integration Tests

- Crop expense/harvest PATCH/DELETE + archive block (existing crops suite extended)
- Fertilizer-only stock-updates list with item_name/category
- Ledger day series zero-fill across 3 days
- Dashboard week aggregates + future-date rejection

## Security Tests

- Unauthenticated PATCH/DELETE crop expense/harvest → `401`
- Unauthenticated `GET /inventory-stock-updates` → `401`
- Unauthenticated ledger series + dashboard aggregates → `401`

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A | Not measured | ⏭ deferred |

## Coverage Report

Critical 032 paths covered (mutations, fertilizer list, series, dashboard TZ bounds, auth). Hard >80% line coverage not enforced (critical-path policy).

## Issues Found

| Issue | Severity | Status |
|-------|----------|--------|
| Web/mobile ops-calc UI | Medium | Open — bolts 033 / 034 |

## Ready for Operations

Bolt `032` complete for API stories. Dependent UI bolts may start.
