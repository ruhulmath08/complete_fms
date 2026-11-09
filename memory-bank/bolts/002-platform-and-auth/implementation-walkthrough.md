---
stage: implement
bolt: 002-platform-and-auth
created: 2026-11-09T09:45:19Z
---

# Implementation Walkthrough: Platform and Auth (Web)

## Summary

Scaffolded a Vite React TypeScript SPA under `web/` for owner signup, sign-in, sign-out, profile, and farm settings against the existing `/api/v1` auth contract. Session tokens live in sessionStorage with refresh-on-401; API errors surface via the shared `message`/`code` shape.

## Structure Overview

Feature-based auth UI under `src/features/auth`, with shared API client, session helpers, auth provider, and shell/routing primitives under `src/shared`. Design tokens live in global CSS variables. Protected routes wrap the authenticated shell.

## Completed Work

- [x] `web/package.json` / Vite config / README / `.env.example` — project scaffold and scripts
- [x] `web/src/main.tsx` / `web/src/App.tsx` — app bootstrap, QueryClient, router
- [x] `web/src/index.css` — shared tokens and layout styles
- [x] `web/src/shared/api/types.ts` — API DTO types
- [x] `web/src/shared/api/errors.ts` — ApiError helper and message extraction
- [x] `web/src/shared/api/client.ts` — fetch wrapper with Bearer auth and refresh retry
- [x] `web/src/shared/auth/session.ts` — sessionStorage token accessors
- [x] `web/src/shared/auth/auth-context.ts` / `AuthProvider.tsx` / `useAuth.ts` — signed-in state and sign-in/out
- [x] `web/src/shared/ui/ProtectedRoute.tsx` — redirect when unsigned
- [x] `web/src/shared/ui/AppShell.tsx` — brand header, nav, sign out
- [x] `web/src/shared/ui/ErrorBanner.tsx` — user-facing API error display
- [x] `web/src/features/auth/api/authApi.ts` — signup/signin/signout/profile/settings calls
- [x] `web/src/features/auth/hooks/useProfileImageUrl.ts` — authenticated profile image blob URL
- [x] `web/src/features/auth/pages/SignUpPage.tsx` — multipart signup form
- [x] `web/src/features/auth/pages/SignInPage.tsx` — credential sign-in
- [x] `web/src/features/auth/pages/HomePage.tsx` — signed-in landing
- [x] `web/src/features/auth/pages/ProfilePage.tsx` — view/edit profile
- [x] `web/src/features/auth/pages/FarmSettingsPage.tsx` — currency settings
- [x] `web/src/test/setup.ts` — Vitest DOM setup (tests in Stage 3)

## Key Decisions

- **sessionStorage for JWT pair**: Fits Bearer API without cookie sessions; tab-scoped; cleared on tab close
- **Refresh on 401 then retry**: Matches API rotation; clears session when refresh fails/reuse detected
- **Signup then sign-in**: Matches API design (signup returns profile only)
- **Profile image via authorized fetch blob**: `<img>` cannot send Authorization headers
- **CSS variables + DM Sans / Fraunces**: Mirrors ux-guide shared tokens without a heavy UI kit

## Deviations from Plan

None material. Vitest tooling installed; automated tests deferred to Stage 3 as defined by the bolt type.

## Dependencies Added

- [x] `react-router-dom` — routing and protected layouts
- [x] `@tanstack/react-query` — server state for profile/settings
- [x] `vitest` + Testing Library + `jsdom` — test harness for Stage 3

## Developer Notes

- Run backend on `:8000` and `npm run dev` in `web/` (or set `VITE_API_BASE_URL`)
- Production build verified with `npm run build`; oxlint clean
- Next stage adds critical-path Vitest coverage for session and error display
