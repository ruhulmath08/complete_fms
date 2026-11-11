---
stage: implement
bolt: 020-design-web
created: 2026-11-11T18:22:41Z
---

# Implementation Walkthrough: Design Web (Shell + Tokens)

## Summary

Signed-in React shell now uses a collapsible left menubar with brand green tokens, a sticky header (notifications placeholder + profile avatar), and a footer. Shared CSS variables drive menu colors so later web bolts can reuse the same foundation.

## Structure Overview

Layout is a two-column grid: sidebar + main column (topbar, content outlet, footer). Profile avatar loads via existing profile API/image hook; sidebar open state persists in localStorage.

## Completed Work

- [x] `web/src/index.css` - Extended design tokens (`--menu-bg`, `--menu-fg`, shell sizes) and shell layout styles
- [x] `web/src/shared/ui/AppShell.tsx` - Left nav, show/hide, header chrome, footer, sign out
- [x] `web/src/shared/ui/AppShell.test.tsx` - Critical-path Vitest for nav, toggle, notifications placeholder

## Key Decisions

- **Reuse `--color-primary` as `--menu-bg`**: Keeps `#2f6a3a` as the single brand green source
- **Avatar fallback initials**: Avoids broken image when profile blob is unavailable in tests/offline
- **Notification panel is client-only placeholder**: Matches FR that backend alerts are out of scope

## Deviations from Plan

- Did not extract separate `SidebarNav` file; kept shell cohesive in one component for this bolt size

## Dependencies Added

- None (used existing React Query + auth APIs)

## Developer Notes

- Sidebar state key: `fms.shell.sidebarOpen`
- Narrow viewports overlay the open sidebar instead of permanently shrinking content
