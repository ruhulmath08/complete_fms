---
unit: 002-poultry-actions-web
bolt: 030-poultry-actions-web
stage: test
status: complete
updated: "2026-11-12T10:12:00Z"
---

# Test Walkthrough - 030-poultry-actions-web

## Summary

| Suite | Passed | Failed |
|-------|--------|--------|
| Vitest poultry feature | 8 | 0 |
| Vitest full `web/` | 34 | 0 |

**Command**:

```bash
cd web && npm test -- --run
# 18 files, 34 passed
```

## Test Files

- [x] `web/src/features/poultry/pages/PoultryDetailPage.test.tsx` - No./Action presence, primary/danger classes, delete confirm, archived Action hide
- [x] Existing poultry list/create/form tests remain green

## Acceptance Criteria Validation

| Story / Criterion | Status |
|-------------------|--------|
| Egg Action Edit/Delete present when writable | ✅ |
| Feeding Action Edit/Delete present when writable | ✅ |
| Delete confirms then calls DELETE API | ✅ |
| Archived group hides Action | ✅ |
| Edit uses `btn-icon-primary`; Delete uses `btn-icon-danger` | ✅ |
| History headers use **No.** (poultry covered in Vitest; cow/crop via implement grep) | ✅ |
| Add egg/feeding forms still render | ✅ |

## Issues Found

None

## Notes

- Manual browser smoke of PATCH save path recommended before ops build; Vitest covers delete + Action chrome critically
- Mobile Action/No. remains bolt `031`
