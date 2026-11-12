---
intent: 004-poultry-history-actions-and-table-polish
version: v0.4.0-e2cd75e
commit: e2cd75e
built: "2026-11-12T10:23:28Z"
status: success
target: local-only
---

# Build: v0.4.0-e2cd75e (local-only)

## Scope

Release verification for intent `004` (bolts `029`–`031`): poultry egg/feeding PATCH/DELETE API, web Action + **No.** polish, mobile Action + **No.** polish.

## Artifact

| Layer | Type | Location / result |
|-------|------|-------------------|
| API | Verified source + tests | `backend/` — **61** pytest passed |
| Web | Vite production bundle | `web/dist/` — **34** Vitest passed; `tsc -b && vite build` OK |
| Mobile | Verified Flutter package | `mobile/` — **39** flutter tests passed |

**Tag**: `v0.4.0-e2cd75e` (documentation tag; no container registry push — local-first)

## Build Environment

- OS: macOS (darwin)
- Backend: Python 3.12 + venv
- Web: Node + Vite 8
- Mobile: Flutter (stable tooling on machine)

## Verification Log Summary

1. `backend`: `python -m pytest -q` → 61 passed
2. `web`: `npm test -- --run` → 34 passed; `npm run build` → `web/dist` produced
3. `mobile`: `flutter test` → 39 passed

## Deployment Policy (this intent)

- **Local machine only** — no staging/production cloud deploy
- Dev “deploy” = run API + web + mobile against local Postgres/API

## Run locally (dev)

```bash
# API (from backend/, venv active; migrate if needed)
alembic upgrade head
uvicorn app.main:app --reload --port 8000

# Web
cd web && npm run dev

# Mobile
cd mobile && flutter run
```

Point Flutter/web at the local API base URL used in existing env config.
