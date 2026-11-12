---
unit: 003-design-mobile
bolt: 027-design-mobile
stage: implement
status: complete
updated: "2026-11-12T08:48:12Z"
---

# Implementation Walkthrough - 027-design-mobile

## Summary

Mobile shell now uses a navigation drawer for farm sections and an AppBar three-dot menu for Profile/Logout (with confirm dialog). Shared async state views cover primary lists.

## Changes

### Nav chrome (001)

- `AppShell`: `Drawer` with Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings
- AppBar right ⋮: icon+title Profile / Sign out
- Logout alert: title, message, Cancel, Confirm
- Home page: welcome + language + menu hint (no crowded button stack)

### Tokens / states (002)

- `LoadingView`, `EmptyView`, `ErrorView` in `async_state_views.dart`
- Wired on cows (+ loading/error on other primary lists)
- Existing `AppTokens` / `AppTheme` retained

## Verification

```bash
cd mobile && flutter test
# 36 passed
```
