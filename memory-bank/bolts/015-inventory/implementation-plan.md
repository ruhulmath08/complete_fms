---
stage: plan
bolt: 015-inventory
created: 2026-11-09T13:06:00Z
---

# Implementation Plan: Inventory (Mobile)

## Objective

Extend the existing Flutter app so a signed-in owner can manage inventory items and stock updates against `/api/v1` inventory endpoints, with Bangla and English strings, matching the web inventory workflows from bolt `014-inventory`.

## Story in Scope

- **003-mobile-inventory**: Mobile inventory items / stock updates with EN+BN localization

## Deliverables

1. Clean Architecture inventory slice under `mobile/lib/`:
   - `domain/` — inventory item / stock update entities, repository port, use cases
   - `data/` — API datasource, mappers, repository impl
   - `presentation/inventory/` — screens (list, create, detail with stock updates)
2. Wire into existing GoRouter (protected shell), GetIt DI, Dio client with Bearer + refresh
3. Screens parity with web:
   - Active items list; include-archived toggle
   - Create item (opening quantity); edit without quantity field
   - Detail: view, archive confirm, stock add/list (add|use), show total_price
   - Archived: read-only (no edit / no new stock updates)
4. Surface API `message` via existing failure patterns; honor `INSUFFICIENT_STOCK`, `INVENTORY_ITEM_ARCHIVED`
5. ARB strings for inventory screens in `en` and `bn`
6. Critical-path tests (mappers and/or l10n)

## Dependencies

1. **`013-inventory` (API)** — complete
2. **`014-inventory` (Web)** — complete (UX/contract reference)
3. **Mobile platform + cows/poultry/crops** — app shell, session, l10n, DI, API client
4. **Endpoints**: same inventory-items / stock-updates contract as web
5. **ADRs to honor (UI only)**: ADR-004 archive write-block

## Technical Approach

1. **Domain entities** mirror API fields (`InventoryCategory`, `StockChangeType`)
2. **`InventoryRepository`** port + Dio-backed impl
3. **Presentation**: follow crops/poultry StatefulWidget + getIt use-case pattern
4. **Navigation**: `/inventory`, `/inventory/new`, `/inventory/:itemId`; home/shell entry
5. **Localization**: ARB keys in `app_en.arb` / `app_bn.arb`; `flutter gen-l10n`
6. **Errors**: `AppFailure.message` inline / SnackBar
7. **Quantity**: create only; later changes via stock updates

## Out of Scope

- Web changes
- Stock update edit/delete; unarchive
- Store release / CI signing

## Acceptance Criteria

- [x] Signed-in owner can list active inventory items and open detail on mobile
- [x] Owner can create/edit/archive items; edit cannot change quantity directly
- [x] Owner can add/list stock updates; quantity and total_price refresh
- [x] Insufficient stock shows API message
- [x] Archived item: readable and write-blocked
- [x] Inventory UI strings in English and Bangla
- [x] Critical-path tests pass

## Relevant Prior Decisions

- ADR-004 constrains archive behavior
- Mobile auth session/refresh unchanged
- Crops mobile feature is a close structural template (parent + child log + archive)
