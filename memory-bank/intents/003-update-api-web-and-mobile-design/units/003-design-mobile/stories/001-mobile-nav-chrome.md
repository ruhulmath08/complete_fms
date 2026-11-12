---
id: 001-mobile-nav-chrome
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
status: complete
priority: must
created: "2026-11-12T07:34:21Z"
updated: "2026-11-12T08:36:33Z"
assigned_bolt: 027-design-mobile
implemented: true
---

# Story: 001-mobile-nav-chrome

## User Story

**As a** farm owner
**I want** a navigation drawer for farm sections and a TitleBar three-dot menu for Profile and Logout
**So that** I can navigate and sign out on a phone without a crowded AppBar

## Acceptance Criteria

- [ ] **Given** a signed-in session on the landing/shell, **When** I open the navigation drawer, **Then** I see: Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings
- [ ] **Given** a drawer item, **When** I tap it, **Then** I navigate to that destination and the active item is indicated
- [ ] **Given** the TitleBar / AppBar, **When** shown, **Then** a **three-dot icon** appears on the **right**
- [ ] **Given** the three-dot icon, **When** I tap it, **Then** a list/menu appears with **icon + title** rows for **Profile** and **Logout**
- [ ] **Given** Profile in the overflow menu, **When** I tap it, **Then** I go to the profile screen
- [ ] **Given** Logout in the overflow menu, **When** I tap it, **Then** an alert dialog shows a proper **title**, **message**, **Confirm**, and **Cancel**
- [ ] **Given** the logout dialog, **When** I tap Confirm, **Then** I am signed out; **When** I tap Cancel, **Then** I stay signed in and the dialog closes
- [ ] **Given** a typical phone width, **When** using the shell, **Then** there is no crowded multi-TextButton overflow in the AppBar
- [ ] **Given** shared tokens, **When** nav is styled, **Then** it uses the production token set (BN/EN strings via l10n)

## Technical Notes

- Use Material 3 `NavigationDrawer` / `Drawer` + `AppBar` actions with `PopupMenuButton` or equivalent three-dot overflow
- Logout confirm copy should be clear (e.g. title “Log out?”, message that the session will end)
- Profile may appear in both drawer and overflow (product owner specified both)

## Dependencies

### Requires

- None

### Enables

- Rest of mobile production UX

## Edge Cases

| Scenario               | Expected Behavior                                              |
| ---------------------- | -------------------------------------------------------------- |
| Long Bangla labels     | Drawer/overflow still readable without AppBar overflow         |
| Drawer open + overflow | Standard Material layering; no stuck scrim after logout cancel |

## Out of Scope

- Web sidebar changes
- Bottom navigation as the primary pattern (drawer is required)
