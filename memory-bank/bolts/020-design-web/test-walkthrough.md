---
stage: test
bolt: 020-design-web
created: 2026-11-11T18:25:24Z
---

# Test Report: Design Web (Shell + Tokens)

## Summary

- **Tests**: 28/28 passed (3 new AppShell + 25 prior feature/auth/shared)
- **Coverage**: Critical-path focus for shell chrome

**Commands**: `npm test -- src/shared/ui/AppShell.test.tsx` and `npm test` in `web/`

## Test Files

- [x] `web/src/shared/ui/AppShell.test.tsx` — nav destinations; sidebar show/hide; notifications empty placeholder; profile fallback initials

## Acceptance Criteria Validation

- ✅ Left menubar with listed destinations; brand green / white text via tokens
- ✅ Menubar show/hide
- ✅ Header + footer; notification icon + profile avatar/fallback
- ✅ Notification empty/placeholder state
- ✅ Shared CSS variables for menu brand colors
- ✅ Critical-path Vitest passes
- ⏭ Full visual browser E2E vs live API: deferred to manual/local

## Issues Found

None for this bolt.

## Notes

Cow form / tables remain for bolt `021-design-web`.
