# System Architecture

## Overview

A modular FastAPI monolith serves as the single source of business rules for one farm and one owner. A React (Vite) SPA and a Flutter mobile app are first-class clients that share the same versioned REST API. Implementation proceeds in small stages across backend, web, and mobile.

## Architecture Style

Modular monolith API + two clients

- One FastAPI application with feature modules: auth/profile, cows, poultry, crops, inventory, income/expenses
- React Vite SPA for web workflows
- Flutter app using Clean Architecture, BLoC, GoRouter, GetIt, Material 3
- Clients do not duplicate core business rules; they present data and collect input

## API Design

Versioned REST JSON under `/api/v1/...`

- Resource-oriented endpoints
- FastAPI OpenAPI as the live contract
- Document request/response fields, validation, and errors for each feature before connecting dependent client screens

## State Management

- **Web:** TanStack Query (or equivalent) for server/API state; React local state/context for light UI state
- **Mobile:** BLoC for presentation state; repositories in the data layer call the API

## Caching Strategy

Client-side caching only for v1

- Rely on TanStack Query and Flutter repository/caching patterns
- No Redis, CDN edge cache, or other server-side cache in the first release

## Security Patterns

Baseline security with stricter token handling

- Email/password auth; passwords hashed (Argon2 or bcrypt)
- JWT access + refresh tokens
- Short-lived access tokens
- Refresh token rotation with reuse detection
- Every private route authorized to the signed-in owner only
- Server-side validation for all writes
- Never log passwords, tokens, or other secrets
- HTTPS expected when hosting is chosen at deploy time

## Components

- **API (FastAPI):** Auth, domain modules, persistence via SQLAlchemy/PostgreSQL
- **Web (React/Vite):** Feature screens against `/api/v1`
- **Mobile (Flutter):** Infrastructure, presentation, domain, data projects
- **PostgreSQL:** System of record (local install in development)

## Data Flow

1. Owner signs in via web or mobile → API issues JWT access + refresh
2. Clients call `/api/v1` with access token
3. API enforces owner ownership, validates input, applies business rules, persists via SQLAlchemy
4. Consistent JSON success/error shapes return to both clients

## Decision Relationships

- Multi-client scope drove a shared versioned REST API and JWT (not cookie-only sessions)
- Modular monolith keeps v1 simple while matching domain module boundaries in the specs
- Harder token rules reduce risk for a long-lived personal farm app without adding staff/RBAC complexity yet
