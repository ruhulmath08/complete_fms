# Backend API (Platform & Auth)

FastAPI modular monolith for the farm management system. This first slice delivers platform foundation plus owner auth, profile, and farm settings.

## Prerequisites

- Python 3.11+
- Local PostgreSQL database (no Docker for v1)

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
- Uploads root: `backend/uploads/` (gitignored). Profile images: `backend/uploads/profile_images/{owner_id}/`. Cow images: `backend/uploads/cow_images/{owner_id}/{cow_id}/`

## Main endpoints

| Method | Path | Auth |
|--------|------|------|
| GET | `/api/v1/health` | Public |
| GET | `/api/v1/config/suggested-units` | Public |
| POST | `/api/v1/auth/signup` | Public (multipart) |
| POST | `/api/v1/auth/signin` | Public |
| POST | `/api/v1/auth/refresh` | Public |
| POST | `/api/v1/auth/signout` | Bearer |
| GET/PATCH | `/api/v1/me` | Bearer |
| GET | `/api/v1/me/profile-image` | Bearer |
| GET/PATCH | `/api/v1/farm-settings` | Bearer |

Errors use `{ "code", "message", "details?" }`.
