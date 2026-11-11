---
stage: test
bolt: 023-design-mobile
created: 2026-11-11T18:47:19Z
---

# Test Report: Design Mobile (Cow Form + Image + Auto Tag)

## Summary

- **Tests**: full `flutter test` suite passed (mapper + form coverage for this bolt)
- **Coverage**: critical-path for auto-tag write payload, image_url mapping, Weight (kg) / validation UX

**Commands**: `flutter test` in `mobile/`

## Test Files

- [x] `mobile/test/data/cows_mappers_test.dart` — `image_url` mapping; `cowWriteToJson` omits `tag_number`; name/breed in write body
- [x] `mobile/test/presentation/cows/cow_form_fields_test.dart` — Weight (kg), auto-tag hint, no create tag field; `buildCowWriteParams` requires name/breed

## Acceptance Criteria Validation

- ✅ Add cow: image control, Weight (kg), no manual tag
- ✅ Create write path omits client tag; API tag consumed via response mapping / detail display
- ✅ Name/breed required client-side
- ✅ Detail wired for authenticated image + weight (live device E2E deferred)
- ✅ Full suite green
- ⏭ Device gallery permission / live upload E2E: deferred to manual

## Issues Found

None for this bolt.

## Notes

Completing this bolt finishes unit `003-design-mobile` and intent `002-design-system-refresh` construction when marked complete.
