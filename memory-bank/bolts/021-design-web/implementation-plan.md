---
stage: plan
bolt: 021-design-web
created: 2026-11-11T18:27:24Z
---

# Implementation Plan: Design Web (Cow form + Tables)

## Objective

Align the React cows UI with bolt `019` API contracts and the refreshed shell: auto-generated tags, cow image + Weight (kg), Bootstrap-style paginated milk/feeding tables (page size 10), and table layouts for cow lists where practical.

## Stories in Scope

- **003-web-add-cow-image-and-labels**: Add-cow image control; Weight (kg); use API-generated tag (no client invent)
- **004-web-milk-feeding-tables**: Milk Bootstrap-style table (No, date+time, unit price, total, note; quantity as needed); feeding aligned table; limit 10 + pagination
- **005-web-tabular-lists**: Prefer table layout for cows list (and similar cow-related tabular views)

## Deliverables

1. **Types / API client**
   - `Cow` + `image_url`; `CowCreateInput` without `tag_number`; required `name`/`breed`
   - `uploadCowImage` / optional `deleteCowImage`; create then PUT image when file chosen
   - Milk/feeding list calls default `limit: 10` with offset pagination

2. **Cow form / create / detail**
   - Remove editable tag on create; show read-only generated tag on detail/edit
   - Required name + breed
   - Label **Weight (kg)**
   - Image file input + preview on create; upload after create (or detail upload); show image on detail
   - Auth-aware cow image fetch pattern (mirror profile image blob fetch if needed)

3. **Milk / feeding on detail**
   - Replace simple lists with HTML tables using Bootstrap-like classes (`table`, striped/bordered/responsive wrapper)
   - Columns milk: No, date+time, quantity (for total), unit price, total (= qty × unit price), note
   - Feeding: No, date+time, feed name, quantity, unit, note (+ pagination)
   - Page size 10; prev/next (or page controls) using `meta.total` / offset

4. **Cows list as table**
   - Convert `CowsListPage` card list to a data table (tag, name, purpose, gender, status, link)

5. **CSS**
   - Table styles in `index.css` matching Bootstrap table look via project tokens (avoid full Bootstrap framework clash), class names `table` / `table-striped` / `table-responsive` as specified in story

6. **Tests**
   - Update `CowForm` / create tests for no tag field, required name/breed, Weight (kg)
   - Detail or component tests for milk table pagination / columns where practical
   - Cows list table renders rows

## Dependencies

1. **`019-design-api`** — complete (auto tag, image, limit 10)
2. **`020-design-web`** — complete (shell/tokens)
3. Existing cows feature module patterns

## Technical Approach

1. Update types + `cowsApi.ts` first
2. Refactor `CowForm` create vs edit modes (create: no tag; edit: tag read-only display outside or disabled)
3. `CowCreatePage`: after create, if image selected → `PUT /cows/{id}/image`, then navigate
4. `CowDetailPage`: image display; milk/feeding tables with local `offset` state and `limit: 10`
5. Shared small `PaginationControls` helper if useful
6. Style tables with tokenized CSS under Bootstrap-compatible class names

## Out of Scope

- Mobile Flutter (022/023)
- Notification backend
- Poultry/crops/inventory/ledger table refresh beyond cows list (Should story focuses on cows tabular preference in this bolt)
- Changing tag after create

## Acceptance Criteria

- [ ] Create cow does not require/send client `tag_number`; name+breed required; tag shown after create from API
- [ ] Weight labeled **Weight (kg)**; cow image selectable on add and visible on detail when uploaded
- [ ] Milk table columns + total; feeding table; both default 10 rows with pagination
- [ ] Cows list presented as a table
- [ ] Critical-path Vitest updated and passing

## Relevant Prior Decisions

- Milk total = quantity × price_per_unit (client-computed)
- Tag format/server generation from bolt 019
