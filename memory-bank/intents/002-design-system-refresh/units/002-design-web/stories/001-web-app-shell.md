---
id: 001-web-app-shell
unit: 002-design-web
intent: 002-design-system-refresh
status: draft
priority: must
created: 2026-11-11T18:01:56Z
assigned_bolt: 020-design-web
implemented: false
---

# Story: 001-web-app-shell

## User Story

**As a** farm owner  
**I want** a left menubar with header and footer on the web app  
**So that** I can navigate farm sections clearly and see my profile chrome

## Acceptance Criteria

- [ ] **Given** I am signed in, **When** I use the web app, **Then** I see a left menubar with Cows, Poultry, Crops, Inventory, Income & expenses, Profile, and Farm settings
- [ ] **Given** the menubar is visible, **When** I view it, **Then** its background is `#2f6a3a` and menu text is white
- [ ] **Given** the menubar is expanded, **When** I choose hide/collapse, **Then** the menubar hides; I can show it again
- [ ] **Given** signed-in pages using the shell, **When** I view the layout, **Then** a header and footer are present
- [ ] **Given** the header, **When** I look at the top-right, **Then** I see a notification icon and my profile image (or fallback avatar)
- [ ] **Given** I click the notification icon, **When** no notification backend exists yet, **Then** I see an empty/placeholder state (not a crash)

## Technical Notes

- Replace/extend current `AppShell` top-nav pattern with left sidebar shell
- Notification is chrome-only for this intent

## Dependencies

### Requires

- None

### Enables

- 002-web-design-tokens
- Other web stories that render inside the shell

## Edge Cases

| Scenario              | Expected Behavior                                  |
| --------------------- | -------------------------------------------------- |
| Missing profile image | Fallback avatar                                    |
| Narrow viewport       | Usable show/hide; content not permanently obscured |

## Out of Scope

- Real-time notification feed
- Mobile navigation shell
