---
unit: 001-platform-and-auth
bolt: 001-platform-and-auth
stage: test
status: complete
updated: 2026-11-09T09:33:13Z
---

# Test Report - Platform and Auth (API)

## Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit | 7 | 0 | 0 | Critical paths exercised |
| Integration | 4 | 0 | 0 | Critical paths exercised |
| Security | 3 | 0 | 0 | - |
| Performance | 0 | 0 | 0 | Not in v1 scope for this bolt |
| **Total** | **14** | **0** | **0** | Critical-path focus (per coding-standards) |

**Command**: `pytest` in `backend/` (SQLite in-memory test DB; Postgres not required for CI-local suite)

## Acceptance Criteria Validation

| Story | Criteria | Status |
|-------|----------|--------|
| 001-api-platform-foundation | Health reachable under `/api/v1` | ✅ |
| 001-api-platform-foundation | Unauthenticated private request → unauthorized `{code,message}` | ✅ |
| 001-api-platform-foundation | Shared paging meta pattern available (`Page`/`PageMeta` schemas) | ✅ (schema present; no list domain endpoint in this bolt) |
| 002-api-owner-signup | Valid signup creates account; password hashed only | ✅ |
| 002-api-owner-signup | Duplicate email/phone rejected with stable codes | ✅ |
| 002-api-owner-signup | Weak password / validation fails | ✅ |
| 003-api-owner-signin-signout | Valid credentials → access + refresh JWTs | ✅ |
| 003-api-owner-signin-signout | Invalid credentials rejected safely | ✅ |
| 003-api-owner-signin-signout | Sign-out / refresh rotation + reuse detection | ✅ |
| 004-api-profile-farm-settings | Profile readable when signed in | ✅ |
| 004-api-profile-farm-settings | Currency default BDT; updatable | ✅ |
| 004-api-profile-farm-settings | Duplicate phone on profile update rejected | ✅ |

## Unit Tests

- Domain rules: email normalize/validate, password rules, currency validation
- Security: Argon2id hash/verify, token SHA-256 hash, JWT access/refresh claims

## Integration Tests

- Health + suggested units
- Full happy path: signup → signin → me → profile image → farm settings → refresh → reuse → signout
- Profile update duplicate phone → `PHONE_ALREADY_EXISTS`

## Security Tests

- Private routes without bearer → `401 UNAUTHORIZED`
- Missing vs wrong password → identical `INVALID_CREDENTIALS` message
- Refresh token rejected as access bearer

## Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response Time (p95) | N/A for v1 bolt | Not measured | ⏭ deferred |
| Throughput | N/A for v1 bolt | Not measured | ⏭ deferred |

## Coverage Report

Critical auth paths covered by automated tests. Hard >80% line coverage not enforced for v1 per coding-standards (critical paths over percentage). Optional follow-up: add `pytest-cov` in a later hardening bolt.

## Issues Found

| Issue | Severity | Status |
|-------|----------|--------|
| Naive vs aware datetime compare on SQLite refresh path | Medium | Fixed (`_as_utc`) |
| Models used Postgres-only UUID type (blocked SQLite tests) | Low | Fixed (SQLAlchemy `Uuid`) |

## Ready for Operations

- [x] All acceptance criteria met (for this API bolt’s stories)
- [ ] Code coverage > 80% (waived: critical-path policy)
- [x] No critical/high severity issues open
- [x] Performance targets N/A / deferred
- [x] Security tests passing
