---
stage: plan
bolt: 026-design-web
created: "2026-11-12T08:43:00Z"
---

# Implementation Plan: 026-design-web

## Objective

Complete web production UX: table Totals + Action (where APIs exist), cow detail chrome, global Back-link removal, Edit/Archive hierarchy, lean pattern docs.

## Stories

- **004** Totals + Action
- **005** Cow chrome / Back / Edit-Archive
- **006** Forms a11y docs (Should)

## Approach

1. Confirm milk/feeding Total+Action remain; extract shared `TableRowActions` icons if reused
2. Convert poultry egg/feeding and crop expense/harvest simple-lists to Milk-style tables with Total where qty×price applies; Action only if PATCH/DELETE exist (cow only today)
3. Cow detail: `.detail-chrome` image left / info right + rectangular placeholder; restyle Edit (primary/outline) vs Archive (danger/ghost)
4. Remove all `← Back to …` links across create/detail pages
5. Short `memory-bank/standards/web-ui-patterns.md` listing shared primitives
6. Vitest updates for cow chrome / Back absence / existing Action paths

## Out of Scope

- New poultry/crop/inventory PATCH/DELETE APIs
- Mobile (027–028)
