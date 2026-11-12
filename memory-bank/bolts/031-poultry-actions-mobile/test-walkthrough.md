---
unit: 003-poultry-actions-mobile
bolt: 031-poultry-actions-mobile
stage: test
status: complete
updated: "2026-11-12T10:18:00Z"
---

# Test Walkthrough — 031-poultry-actions-mobile

## Commands

```bash
cd mobile
flutter gen-l10n
flutter test
```

## Result

**39 tests passed**

## Coverage

| Area | File | Notes |
|------|------|-------|
| l10n | `test/l10n/poultry_l10n_test.dart` | `rowNumber`, `deleteEggConfirm`, `updateEggEntry` EN/BN |
| Mappers | `test/data/poultry_mappers_test.dart` | Existing egg/feeding mapping still green |
| Regression | Full suite | Shell, cows Action/helpers, other modules |

## Acceptance Criteria Validation

| Criterion | Status |
|-----------|--------|
| Egg/feeding Edit/Delete wired via use cases + API | ✅ (implement + compile/test) |
| Delete confirm strings EN/BN | ✅ |
| `rowNumber` / **No.** | ✅ |
| Primary/danger Action colors (poultry + cow) | ✅ (implement) |
| Add path preserved | ✅ |
| `flutter test` green | ✅ 39/39 |

## Manual QA (recommended)

- Poultry detail: edit egg/feeding; confirm PATCH refresh
- Delete with confirm/cancel; archived group hides actions
- Broiler: eggs section remains non-mutable; feeding Action works when writable

## Issues Found

None
