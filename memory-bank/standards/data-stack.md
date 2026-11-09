# Data Stack

## Overview

Local PostgreSQL is the system of record for the single-farm, single-owner product. The FastAPI backend accesses it through SQLAlchemy 2.x, with Alembic managing schema migrations.

## Database

PostgreSQL (local install)

- Installed and run directly on the developer machine (no Docker for v1)
- Stores owner/auth, farm settings, cows, poultry, crops, inventory, and income/expense records
- Managed or cloud-hosted Postgres remains TBD until the first deployment bolt
- pgAdmin may be used for administration during development

## ORM / Database Client

SQLAlchemy 2.x + Alembic

- SQLAlchemy 2.x for models, sessions/queries, and mapping domain data
- Alembic for versioned, reviewable schema migrations
- Business rules stay in the FastAPI layer; the ORM is persistence, not product logic

## Decision Relationships

- PostgreSQL matches the product specs and relational farm-record shape
- SQLAlchemy + Alembic is the standard pairing with FastAPI/Python
- Local Postgres aligns with the local-first, no-Docker infrastructure decision in tech-stack
