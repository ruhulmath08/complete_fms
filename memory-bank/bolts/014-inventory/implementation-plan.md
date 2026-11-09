---
stage: plan
bolt: 014-inventory
created: 2026-11-09T13:01:00Z
---

# Implementation Plan: Inventory (Web)

## Objective

Add signed-in inventory workflows to the existing React (Vite) SPA so the owner can manage inventory items and stock updates against the completed `/api/v1` inventory contract from bolt `013-inventory`, including below-zero prevention messaging.

## Story in Scope

- **002-web-inventory**: Items and stock updates in the browser using shared API error handling

## Deliverables

1. Feature module under `web/src/features/inventory` (API client, types, pages/components)
2. Typed DTOs and TanStack Query usage against:
   - `GET|POST /api/v1/inventory-items`, `GET|PATCH /api/v1/inventory-items/{id}`, `POST .../archive`
   - `GET|POST /api/v1/inventory-items/{id}/stock-updates`
3. Screens/routes (protected, inside `AppShell`):
   - Items list (+ create; include-archived toggle)
   - Item create form (name, category, quantity, unit, price_per_unit, note)
   - Item detail: view/edit/archive; show quantity + computed total_price; stock updates add/list
   - Hide quantity from edit form (API forbids PATCH quantity)
4. Reuse `apiClient`, `ErrorBanner` / `ApiError` (`message` + `code`); surface `INSUFFICIENT_STOCK`
5. Nav link to Inventory from `AppShell`; home CTA alongside cows/poultry/crops
6. Critical-path Vitest (list error banner and/or insufficient-stock / form patterns)

## Dependencies

1. **`013-inventory` (API)** — complete; OpenAPI at backend `/docs`
2. **`011-crops` / `008-poultry` (web)** — SPA patterns to mirror
3. **ADRs**: ADR-004 archive write-block

## Technical Approach

1. **Types** in `web/src/features/inventory/types.ts` (categories enum matching API)
2. **`inventoryApi.ts`**: thin authenticated wrappers
3. **Routes**: `/inventory`, `/inventory/new`, `/inventory/:itemId`
4. **UX**: confirm archive; hide writes when archived; category select; stock change_type add|use; show total_price on list/detail
5. **Styling**: reuse existing CSS / form / list patterns

## Out of Scope

- Flutter (015-inventory)
- Stock update edit/delete; unarchive
- Bangla web localization
- Hosting

## Acceptance Criteria

- [x] Owner can list/create/edit/archive inventory items
- [x] Owner can add/list stock updates; quantity updates on detail
- [x] Insufficient stock shows API message via shared banner
- [x] Archived item: no write actions; API errors surfaced via shared banner
- [x] Critical-path Vitest passes

## Relevant Prior Decisions

- ADR-004 constrains UI behavior
- Web auth session unchanged
- Quantity changes only via stock updates after create
