# Farm Management System (complete_fms)

Single-farm, single-owner record keeping for livestock, crops, inventory, and money — with a shared FastAPI backend, a React web app, and a Flutter mobile app.

## Packages

| Package | Role | Docs |
| ------- | ---- | ---- |
| [`backend/`](backend/) | FastAPI + PostgreSQL API | [`backend/README.md`](backend/README.md) |
| [`web/`](web/) | React (Vite) SPA | [`web/README.md`](web/README.md) |
| [`mobile/`](mobile/) | Flutter app (EN/BN) | [`mobile/README.md`](mobile/README.md) |

## Features

- **Dashboard** — post-login home with day/week/month/year charts (eggs, hen headcount, milk, cow production, expenses, income); default **this week**; no future dates in farm local timezone
- **Auth & account** — sign up / sign in, profile image, farm settings (currency)
- **Cows** — meat/milk records, cow image, milk & feeding history with totals and edit/delete
- **Poultry** — broiler / duck / layer / local groups; egg & feeding history with the same action patterns
- **Crops** — crop names, cycles, expenses, and harvests (edit/delete on history)
- **Inventory** — items and stock updates; fertilizer-category stock as a full history table
- **Income & expenses** — ledger with date-range totals (income / expenses / net) and a trend graph

Web and mobile stay aligned on workflows and design tokens where practical.

## Technologies

- **Backend:** Python 3.11+, FastAPI, SQLAlchemy, Alembic, PostgreSQL
- **Web:** React, Vite, TypeScript, TanStack Query, React Router
- **Mobile:** Flutter, Clean Architecture, BLoC/Cubit, GoRouter, GetIt, Dio, Material 3, EN/BN l10n

## Quick start

1. Start the API — see [`backend/README.md`](backend/README.md) (Postgres, migrations, `uvicorn`)
2. Optional demo farm — `python scripts/seed_demo_data.py` in `backend/` (`demo@completefms.com` / `Password1`)
3. Web — `cd web && npm install && npm run dev`
4. Mobile — `cd mobile && flutter pub get && flutter run`

OpenAPI: `http://localhost:8000/docs`

## Further reading

- Standards & conventions: [`memory-bank/standards/`](memory-bank/standards/)
- Cursor Spaces setup notes: [docs/01-install-spaces.md](docs/01-install-spaces.md), [docs/02-start-working.md](docs/02-start-working.md)
