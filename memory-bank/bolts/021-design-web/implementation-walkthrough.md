---
stage: implement
bolt: 021-design-web
created: 2026-11-11T18:30:14Z
---

# Implementation Walkthrough: Design Web (Cow form + Tables)

## Summary

Web cows UI now matches the refreshed API: auto-generated tags, optional cow images, Weight (kg), Bootstrap-style milk/feeding tables with page size 10, and a tabular cows list.

## Structure Overview

Cows feature types/API updated first; form and create/detail pages consume the new contract; shared table CSS and pagination controls support history tables.

## Completed Work

- [x] `web/src/features/cows/types.ts` - Create input without tag; `image_url` on Cow
- [x] `web/src/features/cows/api/cowsApi.ts` - Image upload; milk/feeding default limit 10
- [x] `web/src/features/cows/hooks/useCowImageUrl.ts` - Authenticated cow image blob URL
- [x] `web/src/features/cows/components/CowForm.tsx` - Image, Weight (kg), required name/breed, no create tag
- [x] `web/src/features/cows/components/PaginationControls.tsx` - Prev/next for tables
- [x] `web/src/features/cows/pages/CowCreatePage.tsx` - Create then optional image upload
- [x] `web/src/features/cows/pages/CowDetailPage.tsx` - Image, milk/feeding tables + pagination
- [x] `web/src/features/cows/pages/CowsListPage.tsx` - Table list layout
- [x] `web/src/index.css` - Bootstrap-like `.table` styles
- [x] Updated cows Vitest files for new form/list behavior

## Key Decisions

- **Client-computed milk total**: quantity × unit price in the table
- **Tokenized table CSS** instead of full Bootstrap package to avoid style collisions
- **Image after create**: JSON create then `PUT .../image` when a file is chosen

## Deviations from Plan

- None material

## Dependencies Added

- None

## Developer Notes

- Edit mode shows read-only tag; create never sends `tag_number`
- Milk/feeding queries include `offset` in the React Query key
