---
stage: plan
bolt: 027-design-mobile
created: "2026-11-12T08:46:00Z"
---

# Implementation Plan: 027-design-mobile

## Objective

Ship mobile foundation: navigation drawer, TitleBar ⋮ Profile/Logout with confirm dialog, shared empty/loading/error, token-aligned landing.

## Approach

1. Replace AppBar TextButtons with `Drawer` destinations + `PopupMenuButton` (⋮)
2. Logout `AlertDialog` (title, message, Confirm, Cancel) → `SessionCubit.signOut` on Confirm
3. Add BN/EN strings; slim Home to welcome + language + menu hint
4. Shared `LoadingView` / `EmptyView` / `ErrorView`; wire primary list pages
5. Widget tests for drawer + logout dialog
