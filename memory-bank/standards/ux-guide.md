# UX Guide

## Overview

Keep web and mobile visually consistent through shared design tokens. Flutter uses Material 3; the React SPA mirrors the same colors, typography, and spacing with a light CSS approach. Both clients support practical accessibility and cover phone-to-desktop usage without a heavy design system.

## Design System / Component Library

Shared tokens + Material 3

- Define a single token set for color, typography, and spacing
- Flutter: Material 3 components themed from those tokens
- React: mirror tokens; prefer simple composed components over a heavy third-party UI kit in v1
- Brand and product screens should feel like one product across platforms

## Styling Approach

- **Web:** CSS variables + plain CSS / CSS modules
- **Mobile:** Flutter Material 3 `ThemeData` / component themes
- Avoid divergent one-off palettes per screen

## Accessibility

Practical WCAG-minded v1

- Semantic HTML on web; Flutter semantics where it matters
- Keyboard-usable web forms and focus states
- Visible labels (not placeholder-only)
- Contrast-aware tokens
- No formal full-audit release gate for v1; fix obvious barriers as features ship

## Responsive Design Strategy

Mobile app + responsive web

- Flutter is the primary native phone experience
- React SPA layouts should work from phone browser through desktop with simple responsive breakpoints
- Prefer one clear primary action per screen; avoid dense dashboard clutter in v1 record-keeping flows

## Localization

- Mobile: Bangla and English
- Keep user-facing strings externalizable
- Align web copy structure so shared product language stays consistent where practical
