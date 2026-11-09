---
stage: plan
bolt: 002-platform-and-auth
created: 2026-11-09T09:39:06Z
---

# Implementation Plan: Platform and Auth (Web)

## Objective

Scaffold the React (Vite) web app and deliver owner signup, sign-in, sign-out, profile, and farm settings screens against the completed `/api/v1` auth contract from bolt `001-platform-and-auth`.

## Story in Scope

- **005-web-auth-and-settings**: Sign up, sign in, sign out, manage profile/settings in the browser using the same API rules

## Deliverables

1. Vite + React + TypeScript app under `web/`
2. Shared design tokens (CSS variables) aligned with ux-guide
3. API client for auth/profile/settings (typed, snake_case JSON)
4. Auth session handling: store access + refresh tokens securely for SPA use; attach Bearer access token; refresh-on-401 with rotation
5. Screens/routes:
   - Sign up (multipart including profile image)
   - Sign in
   - Authenticated shell with sign out
   - Profile view/edit
   - Farm settings (currency)
6. User-visible API errors via `message`; branching via `code` where needed
7. Minimal Vitest + Testing Library coverage for critical auth UI paths

## Dependencies

1. **`001-platform-and-auth` (API)** — complete; OpenAPI live at backend `/docs`
2. **Endpoints consumed**:
   - `POST /api/v1/auth/signup` (multipart)
   - `POST /api/v1/auth/signin`
   - `POST /api/v1/auth/refresh`
   - `POST /api/v1/auth/signout`
   - `GET|PATCH /api/v1/me`
   - `GET /api/v1/me/profile-image`
   - `GET|PATCH /api/v1/farm-settings`
   - `GET /api/v1/config/suggested-units` (optional display)
3. **Prior ADRs** (constraints, not re-decided here): Argon2/JWT/family reuse live on API; web only consumes tokens
4. **Libraries (planned)**: React Router, TanStack Query, Vite env for API base URL

## Technical Approach

1. **Scaffold**: `web/` with Vite React-TS; feature folders under `src/features/auth` and shared `src/shared` (api client, tokens CSS, UI primitives)
2. **Token storage**: Prefer `sessionStorage` for access + refresh in v1 SPA (survives refresh within tab; cleared on tab close). Document trade-off vs httpOnly cookies (API is Bearer JWT, not cookie session)
3. **Auth flow**: Signup returns profile only → navigate to sign-in. Sign-in stores tokens. Protected routes redirect unauthenticated users to sign-in. Refresh interceptor rotates tokens; on `REFRESH_TOKEN_REUSE` / invalid refresh, clear session and force sign-in
4. **Forms**: Visible labels; show API `message` on failure; map common codes (`EMAIL_ALREADY_EXISTS`, `PASSWORD_INVALID`, `INVALID_CREDENTIALS`, etc.)
5. **Styling**: CSS variables for color/type/spacing; light, non-dashboard first screens; one primary CTA per view
6. **Config**: `VITE_API_BASE_URL` default `http://localhost:8000`

## Out of Scope

- Flutter / mobile UI (bolt 003)
- Domain modules (cows, etc.)
- Bangla web localization depth (optional later)
- Hosting / Docker

## Acceptance Criteria

- [ ] Owner can sign up from web (including profile image) against the API
- [ ] Owner can sign in and receive tokens stored for subsequent authenticated calls
- [ ] Owner can sign out; private screens become inaccessible
- [ ] Validation/API errors show the API `message` and use `code` where branching is needed
- [ ] Signed-in owner can view/edit profile and farm settings; UI reflects saved API values
- [ ] Protected routes require a valid session
- [ ] Critical-path tests pass for auth session / error display behaviors

## Relevant Prior Decisions

- ADR-001 / ADR-002 / ADR-003 apply on the API side; web must honor refresh rotation and reuse failure by forcing re-login
