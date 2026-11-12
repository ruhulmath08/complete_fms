# Web app (Platform & Auth)

React (Vite) SPA for farm owner signup, sign-in, profile, and farm settings.

## Setup

```bash
cd web
cp .env.example .env
npm install
npm run dev
```

Requires the backend at `VITE_API_BASE_URL` (default `http://localhost:8000`).

## Scripts

- `npm run dev` — local Vite server
- `npm run build` — typecheck + production build
- `npm run test` — Vitest
- `npm run lint` — oxlint

## UI patterns

Shared shell, table, pagination, and state primitives are documented in
[`../memory-bank/standards/web-ui-patterns.md`](../memory-bank/standards/web-ui-patterns.md).
