---
unit: 002-design-web
bolt: 025-design-web
stage: test
status: complete
updated: "2026-11-12T08:42:00Z"
---

# Test Walkthrough - 025-design-web

## Summary

| Suite | Passed | Failed |
|-------|--------|--------|
| Vitest (`web/`) | 31 | 0 |

**Command**: `cd web && npm test -- --run`

## Acceptance spot-checks

| Story | Check | Status |
|-------|-------|--------|
| 001 | Skip link + `#main-content` | ✅ AppShell.test |
| 001 | Escape closes notify/profile | ✅ AppShell.test |
| 002 | Lists request `limit: 10` | ✅ list page tests |
| 002 | Tables render for entity lists | ✅ list page tests |
| 003 | Error still `role="alert"` | ✅ existing list error tests |

## Notes

- Scrim is CSS-gated at ≤800px; covered by markup (`app-shell__scrim`) rather than viewport unit test
- Action/Total column tests belong to bolt 026
