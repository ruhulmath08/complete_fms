---
stage: test
bolt: 002-platform-and-auth
created: 2026-11-09T09:46:18Z
---

# Test Report: Platform and Auth (Web)

## Summary

- **Tests**: 6/6 passed
- **Coverage**: Critical-path focus (session, API error display, protected route)

**Command**: `npm run test` in `web/`

## Test Files

- [x] `web/src/shared/auth/session.test.ts` — token store/clear/signed-in state in sessionStorage
- [x] `web/src/shared/api/errors.test.ts` — ApiError `code`/`message` for UI branching
- [x] `web/src/features/auth/pages/SignInPage.test.tsx` — invalid credentials show API `message`
- [x] `web/src/shared/ui/ProtectedRoute.test.tsx` — unsigned users redirected to sign-in

## Acceptance Criteria Validation

- ✅ **Tokens stored for subsequent calls**: session helpers persist access/refresh; AuthProvider sets them on sign-in
- ✅ **API errors show `message` / branch on `code`**: SignInPage + ApiError tests
- ✅ **Profile/settings reflect API values**: implemented in Stage 2 (manual/API-backed forms); not duplicated as network E2E here
- ✅ **Protected routes require session**: ProtectedRoute redirect test

## Issues Found

None.

## Notes

Full browser E2E against a live FastAPI instance is deferred to local/manual verification (`backend` + `web` running). Automated suite covers the critical SPA session and error-display contracts without requiring Postgres.
