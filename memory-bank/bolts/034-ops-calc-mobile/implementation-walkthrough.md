---
unit: 003-ops-calc-mobile
bolt: 034-ops-calc-mobile
stage: implement
status: complete
updated: '2026-11-13T08:20:00Z'
---

# Implementation Walkthrough - 034-ops-calc-mobile

## Summary

Wired Flutter UI for crop expense/harvest Action, fertilizer stock table, ledger range graph, and Dashboard post-login landing with EN/BN, consuming bolt `032` APIs.

## Changes

### Shared

- `presentation/shared/widgets/series_chart.dart` — CustomPainter multi-series chart
- `domain/date_ranges.dart` — Monday week start, clamp to today, grain helpers
- `language_selector.dart` moved for dashboard reuse

### Crops (001)

- PATCH/DELETE through crops API → repo → use cases → DI
- `crop_cycle_detail_page` DataTable Action (primary edit / danger delete)

### Inventory (002)

- `ListFertilizerStockUpdates` + `fertilizer_stock_table` on inventory list

### Ledger (003)

- `GetLedgerSeries` + chart below Apply; totals retained; series `to` clamped to today

### Dashboard (004)

- New dashboard feature (API, entities, repo, use case, page)
- `/dashboard` post-login landing; shell nav first; removed `/home` welcome page
- Period chips + date pickers max=today; six series charts

### l10n

- New EN/BN keys for dashboard, fertilizer stock, chart, crop delete confirms

## Verification

```bash
cd mobile && flutter gen-l10n && flutter test
# 68 passed
```
