---
stage: plan
bolt: 020-design-web
created: 2026-11-11T18:21:12Z
---

# Implementation Plan: Design Web (Shell + Tokens)

## Objective

Replace the top-nav `AppShell` with a signed-in layout that uses a collapsible left menubar (`#2f6a3a` / white text), header (notification placeholder + profile image), footer, and shared CSS design tokens/components reusable by later web bolts.

## Stories in Scope

- **001-web-app-shell**: Left sidebar nav, show/hide, header, footer, notification icon, profile image
- **002-web-design-tokens**: Shared tokens/variables and reusable shell pieces (not one-off hardcodes)

## Deliverables

1. Extended design tokens in `web/src/index.css` (or `web/src/shared/ui/tokens.css` imported from index) for:
   - Menu green (`--color-primary` already `#2f6a3a`), white-on-green menu text, sidebar width, header/footer heights, shell layout gaps
2. Refactored `AppShell` (and small extracted pieces if useful, e.g. `SidebarNav`, header chrome) with:
   - Left menubar links: Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings
   - Show/hide (collapse) control for the menubar
   - Header with brand/title area + top-right notification icon (placeholder empty state) + profile image (from `/api/v1/me` / profile-image URL, fallback avatar)
   - Footer on signed-in shell pages
   - Sign out available from shell (header or sidebar footer area)
3. Layout CSS so main content sits beside the sidebar (full usable width; not capped only by old narrow shell if it fights the sidebar)
4. Vitest critical-path coverage for shell: nav destinations present; toggle show/hide; notification placeholder; profile image/fallback rendering (mock auth/profile as needed)

## Dependencies

1. Existing React SPA auth (`ProtectedRoute`, `useAuth`) — no new backend required for shell chrome
2. Existing `GET /api/v1/me` + profile image URL pattern for avatar
3. `--color-primary: #2f6a3a` already in `:root` — reuse/extend rather than duplicate

## Technical Approach

1. **Tokens first**: Add `--menu-bg`, `--menu-fg`, `--shell-sidebar-width`, `--shell-header-height`, etc.; keep primary green aligned to `#2f6a3a`
2. **Layout**: CSS grid/flex `app-shell` with `aside` + `main` column containing header, outlet, footer
3. **Collapse**: React state (and optional `localStorage` key) for sidebar open/closed; collapsed state still allows expand control
4. **Profile chip**: Fetch owner profile when signed in (TanStack Query or light effect); show `profile_image_url` with auth-aware `<img>` or fallback initials
5. **Notification**: Button/icon opens a simple empty panel or toast-less placeholder (“No notifications”)
6. **Tests**: Component test of `AppShell` with `MemoryRouter` + mocked auth/profile

## Out of Scope

- Cow form, milk/feeding tables, tabular lists (bolt `021-design-web`)
- Real notification backend
- Mobile Flutter shell
- Changing public sign-in/sign-up pages to use the signed-in shell

## Acceptance Criteria

- [ ] Signed-in pages show left menubar with all listed destinations; background `#2f6a3a`; white/light menu text
- [ ] Menubar can be shown and hidden
- [ ] Header and footer present on shell pages; header top-right has notification icon + profile image/fallback
- [ ] Notification interaction shows empty/placeholder state without crash
- [ ] Menu brand colors come from shared CSS variables/tokens
- [ ] Critical-path Vitest for shell passes

## Relevant Prior Decisions

- Intent `002` FR-1 / FR-9; primary green already chosen in web CSS
- Bolt `019` complete (API) but not required for this shell-only bolt
