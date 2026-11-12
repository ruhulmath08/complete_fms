---
id: 027-design-mobile
unit: 003-design-mobile
intent: 003-update-api-web-and-mobile-design
type: simple-construction-bolt
status: planned
stories:
  - 001-mobile-nav-chrome
  - 002-mobile-tokens-and-states
created: "2026-11-12T07:34:21Z"
requires_bolts: []
enables_bolts:
  - 028-design-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 1
  testing_scope: 2
---

# Bolt: 027-design-mobile

## Objective

Ship mobile foundation: **navigation drawer** (Cows → Farm settings), TitleBar **three-dot** overflow (Profile + Logout with confirm dialog), and mirrored tokens with shared empty/loading/error states.

## Stories Included

- [ ] **001-mobile-nav-chrome**: Drawer + three-dot Profile/Logout dialog - Priority: Must
- [ ] **002-mobile-tokens-and-states**: Tokens + empty/loading/error - Priority: Must

## Expected Outputs

- `AppShell` with drawer destinations and AppBar ⋮ menu
- Logout alert dialog (title, message, Confirm, Cancel)
- Shared state widgets + token alignment

## Dependencies

### Bolt Dependencies

- None

### Enables

- 028-design-mobile
