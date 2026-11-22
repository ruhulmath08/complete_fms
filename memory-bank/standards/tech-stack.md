# Tech Stack

## Overview

Full-product farm management system: FastAPI backend, React (Vite) web app, and Flutter mobile app. All three clients are in scope for the first release; implementation proceeds in small stages. Business rules live in the backend API so web and mobile stay consistent.

## Languages

Python, TypeScript, Dart

- **Python** — FastAPI backend and shared business rules
- **TypeScript** — React web SPA
- **Dart** — Flutter mobile app

## Framework

FastAPI + React (Vite SPA) + Flutter

- **Backend:** FastAPI with modular feature packages (auth, cows, poultry, crops, inventory, income/expenses)
- **Web:** React SPA scaffolded/served via Vite; consumes the FastAPI API
- **Mobile:** Flutter in one package. Clean Architecture folders (`domain`, `data`, `presentation`, `infrastructure`); domain stays pure Dart. BLoC/Cubit, GoRouter, GetIt, and a single Dio `ApiClient`. UI widgets from `material_ui` / `cupertino_ui`, themed as Material 3. Bangla and English localization

## Authentication

JWT access + refresh tokens

Custom FastAPI authentication using email/password for a single owner account. Access and refresh tokens support both React and Flutter clients. Signed-out users cannot access private farm data.

## Infrastructure & Deployment

Local-first development without Docker

- Run FastAPI, the React Vite app, and PostgreSQL directly on the developer machine
- Flutter connects to the local API during development
- Cloud/PaaS hosting remains TBD until the first deployment bolt
- Keep infrastructure simple for v1

## Package Manager

- **Python:** pip + venv
- **TypeScript/web:** npm
- **Dart/Flutter:** pub

## Decision Relationships

- Multi-client (web + mobile) drove JWT over cookie sessions
- Local Postgres without Docker keeps v1 ops light; hosting is deferred
- FastAPI as the single source of business rules lets both clients share validation and authorization behavior
