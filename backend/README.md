# Backend API

FastAPI modular monolith for the farm management system. Serves the React web app and Flutter mobile client: auth, farm settings, domain CRUD/history, and Dashboard aggregates.

## Domains

| Module                        | Responsibility                                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Auth / me / farm-settings** | Signup (multipart + profile image), JWT sign-in/refresh/sign-out, profile, currency settings, suggested units |
| **Cows**                      | Cow CRUD, cow image upload/serve, milk productions & feedings (incl. PATCH/DELETE)                            |
| **Poultry**                   | Poultry groups, egg productions & feedings (incl. PATCH/DELETE)                                               |
| **Crops**                     | Crop names, cycles, expenses & harvests (incl. PATCH/DELETE on history)                                       |
| **Inventory**                 | Items, stock updates; fertilizer-category stock listing/filters as needed by clients                          |
| **Income & expenses**         | Ledger entries, date-range totals / series for graphs                                                         |
| **Dashboard**                 | Period aggregates (eggs, hen headcount, milk, cow production, expenses, income)                               |

Owner-scoped; single farm. Errors use `{ "code", "message", "details?" }`.

## Prerequisites

- Python 3.11+
- Local PostgreSQL (no Docker for v1)

## Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# edit DATABASE_URL and SECRET_KEY
createdb complete_fms   # or create via psql/pgAdmin
alembic upgrade head
mkdir -p uploads/profile_images uploads/cow_images
uvicorn app.main:app --reload --port 8000
```

- Health: `GET http://localhost:8000/api/v1/health`
- OpenAPI: `http://localhost:8000/docs`
- Uploads root: `backend/uploads/` (gitignored)
  - Profile images: `uploads/profile_images/{owner_id}/`
  - Cow images: `uploads/cow_images/{owner_id}/{cow_id}/`

## Demo data (presentations / manual testing)

Seeds a full farm (cows, milk, poultry, eggs, crops, fertilizer stock, ledger) spanning the last ~2–3 weeks so Dashboard week/month charts look populated.

```bash
cd backend
source .venv/bin/activate
alembic upgrade head
python scripts/seed_demo_data.py          # first time
python scripts/seed_demo_data.py --reset  # wipe & reseed demo owner
```

| Field    | Value                  |
| -------- | ---------------------- |
| Email    | `demo@completefms.com` |
| Password | `Password1`            |

## Main route groups

All under `/api/v1` (see OpenAPI for full contracts):

| Prefix / area                                    | Notes                            |
| ------------------------------------------------ | -------------------------------- |
| `/health`, `/config/suggested-units`             | Public                           |
| `/auth/*`                                        | Signup, signin, refresh, signout |
| `/me`, `/me/profile-image`, `/farm-settings`     | Owner profile & settings         |
| `/cows`, `/cows/{id}/…`                          | Cows, image, milk, feeding       |
| `/poultry-groups`, `…/eggs`, `…/feedings`        | Poultry history                  |
| `/crop-names`, `/crop-cycles`, expenses/harvests | Crops                            |
| `/inventory-items`, `/inventory-stock-updates`   | Inventory                        |
| `/ledger-entries`                                | Income & expenses                |
| `/dashboard`                                     | Period aggregates for charts     |

## Related

- React web app: [`../web/README.md`](../web/README.md)
- Flutter mobile app: [`../mobile/README.md`](../mobile/README.md)
- Repo overview: [`../README.md`](../README.md)
- API conventions: [`../memory-bank/standards/api-conventions.md`](../memory-bank/standards/api-conventions.md)
