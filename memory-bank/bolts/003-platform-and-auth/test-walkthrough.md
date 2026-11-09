---
stage: test
bolt: 003-platform-and-auth
created: 2026-11-09T09:57:12Z
---

# Test Report: Platform and Auth (Mobile)

## Summary

- **Tests**: 7/7 passed
- **Coverage**: Critical-path domain/data/presentation (failures, mappers, session, locale)

**Command**: `flutter test` in `mobile/`

## Test Files

- [x] `mobile/test/domain/failures_test.dart` — API `code`/`message` failure surface
- [x] `mobile/test/data/auth_mappers_test.dart` — profile/settings/token JSON mapping
- [x] `mobile/test/presentation/session_cubit_test.dart` — bootstrap signed-in + sign-out
- [x] `mobile/test/presentation/locale_cubit_test.dart` — EN/BN locale switching
- [x] `mobile/test/widget_test.dart` — suite smoke load

## Acceptance Criteria Validation

- ✅ **Tokens stored and used for local API in dev**: implemented via TokenStore + Dio (manual device smoke against running API)
- ✅ **API errors show user-facing `message`**: AppFailure + UI catch paths; unit-tested failure shape
- ✅ **Bangla and English strings**: LocaleCubit + ARB l10n; locale switch tested
- ✅ **Profile/settings via API**: implemented; mapper coverage for response shapes

## Issues Found

None in automated suite.

## Notes

Full emulator/device E2E against live FastAPI is deferred to local smoke (`flutter run` + backend). Automated suite focuses on domain/BLoC/mapper critical paths per coding-standards.
