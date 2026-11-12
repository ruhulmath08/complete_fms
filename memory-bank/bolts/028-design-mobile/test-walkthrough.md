---
unit: 003-design-mobile
bolt: 028-design-mobile
stage: test
status: complete
updated: "2026-11-12T09:30:00Z"
---

# Test Walkthrough — 028-design-mobile

## Commands

```bash
cd mobile
flutter gen-l10n
flutter test
```

## Result

**39 tests passed** (was 36 at 027).

## Added / updated coverage

| Area | File | Notes |
|------|------|-------|
| Mappers | `test/data/cows_mappers_test.dart` | `total`, `unit_cost` on milk/feeding |
| l10n | `test/l10n/cows_l10n_test.dart` | Total, unit cost, pagination summary |
| UI helper | `test/presentation/cows/row_total_test.dart` | API total vs computed fallback |

## Manual QA (recommended)

- Cow detail: paginate milk/feeding past 10 rows
- Edit milk/feeding row; confirm PATCH refresh
- Delete with confirm; archived cow hides actions
