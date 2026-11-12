---
unit: 002-design-web
bolt: 026-design-web
stage: implement
status: complete
updated: "2026-11-12T08:45:01Z"
---

# Implementation Walkthrough - 026-design-web

## Summary

Finished web production UX: cow detail chrome, global Back-link removal, Edit/Archive hierarchy, history tables with Totals where meaningful, and lean UI pattern docs. Milk/feeding Action+Total remain (API-backed).

## Changes

### 004 Totals + Action

- Cow milk/feeding: Total + Action Edit/Delete (already wired to PATCH/DELETE)
- Inventory list + ledger list: Total column
- Poultry eggs: Milk-style table + Total (qty × unit price); poultry feeding table
- Crop expenses/harvests: Milk-style tables with Total / Sale total
- Action Edit/Delete only where APIs exist (cow milk/feeding); other histories are display tables

### 005 Cow chrome / Back / Edit-Archive

- `detail-chrome`: rectangular image left, info right; placeholder when no photo
- Removed all `← Back to …` links (13 pages)
- Detail toolbars: Edit = primary, Archive = `btn-danger-ghost` (confirm retained)

### 006 Docs

- `memory-bank/standards/web-ui-patterns.md`
- Link from `web/README.md`

## Verification

```bash
cd web && npm test -- --run && npm run build
# 31 passed; build OK
```
