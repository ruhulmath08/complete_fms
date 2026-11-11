---
stage: plan
bolt: 023-design-mobile
created: 2026-11-11T18:39:30Z
---

# Implementation Plan: Design Mobile (Cow Form + Image + Auto Tag)

## Objective

Align Flutter cow create/detail with API contracts from bolt `019`: no client tag on create, Weight (kg) labeling, optional cow image pick/upload/display, and required name/breed validation — matching web parity from `021`.

## Stories in Scope

- **003-mobile-cow-create-refresh**: Image control + Weight (kg); create with optional image navigates as today
- **004-mobile-consume-auto-tag-and-image**: API-generated tag display; image on detail; name/breed required

## Deliverables

1. **Domain/data**
   - Add `imageUrl` (nullable) on `Cow`; map `image_url` in `mapCow`
   - `CowWriteParams` / `cowWriteToJson`: omit `tag_number` on create; keep tag only if API update still accepts it (prefer omit on create; edit may leave tag read-only and out of write body if PATCH ignores unknown — mirror web: create without tag)
   - `CowsApi` + repository: `uploadCowImage(cowId, file)` → `PUT /api/v1/cows/:id/image` multipart; optional authenticated image bytes getter for display (reuse auth profile image pattern)
2. **Form UX** (`cow_form_fields.dart` / create/detail pages)
   - Remove editable tag on create; show read-only API tag on edit/detail
   - Label weight as **Weight (kg)** (EN) + BN equivalent in ARB; numeric keyboard
   - Image picker (gallery) with preview; optional; permission failure → message, allow create without image
   - Require name + breed before submit
3. **Create flow**
   - `CreateCow` JSON → if local image selected, upload → navigate to detail with returned cow
4. **Detail**
   - Show cow image (or placeholder) + weight in read-only summary; tag from API
5. **Tests**
   - Mapper: `image_url` mapping; write JSON omits `tag_number`
   - Widget/unit smoke for form label / required fields where practical
   - Full `flutter test` green

## Dependencies

1. Bolt `019` API: auto tag, image routes, required name/breed
2. Bolt `022` tokens available for chrome consistency
3. Existing `image_picker` + auth `FormData` upload pattern

## Technical Approach

1. Extend entity/mapper/API first (compile-safe contracts)
2. Update form fields + l10n strings
3. Wire create page: create then upload; detail: load image with auth headers
4. Keep milk/feeding UX unchanged unless a tiny layout tweak is needed for image header

## Out of Scope

- Changing tag generation algorithm
- Web SPA changes
- List cards showing thumbnails (optional nice-to-have; not required if detail shows image)
- Full notification system

## Acceptance Criteria

- [ ] Add cow: no manual tag; Weight (kg); optional image pick/preview
- [ ] Create with name+breed succeeds; displayed tag is API-generated
- [ ] Missing name/breed blocked client-side
- [ ] Detail shows image when present (placeholder on failure); tag visible
- [ ] Mapper/API tests + full suite pass

## Relevant Prior Decisions

- Web: create then `uploadCowImage`; no `tag_number` on create
- Image optional; gallery permission denial must not block create
