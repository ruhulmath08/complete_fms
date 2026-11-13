# Web app

React (Vite) SPA for a single-farm owner: record keeping across cows, poultry, crops, inventory, and income/expenses, plus a Dashboard for period analytics. Talks to the FastAPI backend at `VITE_API_BASE_URL`.

## Features

| Area | What you can do |
|------|-----------------|
| **Dashboard** | Post-login home. Period day / week / month / year (default **this week**). Charts for egg production, hen headcount, milk, cow production, expenses/cost, and income. Future dates blocked in the farm local timezone. |
| **Auth & account** | Sign up (multipart + profile image), sign in / out, profile edit, farm settings (currency). |
| **Cows** | List / create / detail with cow image; milk production and feeding histories as paginated tables with row **Total**, **Edit** / **Delete** actions. |
| **Poultry** | Groups (broilers, ducks, layers, local); egg production and feeding histories with the same Action / Total / **No.** column patterns as cows. |
| **Crops** | Crop names and cycles; expenses and harvests with Edit / Delete actions (confirm on delete). |
| **Inventory** | Items and stock updates; fertilizer-category stock changes as a paginated Action-capable table. |
| **Income & expenses** | Ledger list with date-range filter; **Total income / Total expenses / Net** plus a trend graph for the applied range. |

Signed-in shell: collapsible left sidebar, header (notifications placeholder + profile), footer. Design tokens and shared chrome live in `src/index.css` / `shared/ui/AppShell.tsx`.

## Setup

```bash
cd web
cp .env.example .env
npm install
npm run dev
```

Requires the backend at `VITE_API_BASE_URL` (default `http://localhost:8000`). For demo login data, see [`../backend/README.md`](../backend/README.md) (seed script).

## Scripts

- `npm run dev` — local Vite server
- `npm run build` — typecheck + production build
- `npm run test` — Vitest
- `npm run test:watch` — Vitest watch mode
- `npm run lint` — oxlint
- `npm run preview` — preview production build

## Structure

```text
src/
  features/     # auth, dashboard, cows, poultry, crops, inventory, income-expenses
  shared/       # auth session, API client helpers, UI primitives, pagination
  App.tsx       # routes (Dashboard is `/` redirect target)
```

## UI patterns

Shared shell, tables, pagination, Action column, empty/loading/error, and form conventions are documented in
[`../memory-bank/standards/web-ui-patterns.md`](../memory-bank/standards/web-ui-patterns.md).

Highlights:

- Default page size: `shared/constants/pagination.ts` (`DEFAULT_PAGE_SIZE` = 10)
- History tables: row index column **No.**; money **Total** when meaningful; Edit = primary, Delete = danger + confirm
- States: `LoadingState`, `EmptyState`, `ErrorBanner`

## Related

- Backend API: [`../backend/README.md`](../backend/README.md)
- Flutter client: [`../mobile/README.md`](../mobile/README.md)
- Repo overview: [`../README.md`](../README.md)
