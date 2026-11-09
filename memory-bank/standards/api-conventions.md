# API Conventions

## Overview

The FastAPI backend exposes a versioned REST JSON API shared by the React and Flutter clients. Contracts are documented per feature before dependent screens are built.

## API Style

REST JSON

- Resource-oriented endpoints
- Plural resource names where natural (`/cows`, `/poultry-groups`, `/crop-cycles`)
- JSON request and response bodies
- snake_case field names in JSON

## API Versioning

URL path versioning under `/api/v1/...`

- Breaking changes require a new version path
- Non-breaking additive changes may stay on `v1`

## Response Format

Direct resource JSON for single resources.

List endpoints that need paging use:

```json
{
  "items": [],
  "meta": {
    "total": 0,
    "limit": 20,
    "offset": 0
  }
}
```

Auth token responses may use a small dedicated shape (e.g. `access_token`, `refresh_token`, `token_type`, `expires_in`) documented in the auth feature contract.

## Error Response Format

```json
{
  "code": "STOCK_BELOW_ZERO",
  "message": "Stock quantity cannot go below zero.",
  "details": {}
}
```

- Pair with the correct HTTP status code
- `code` is stable for client branching
- `message` is safe to show to the owner
- `details` is optional (validation field errors, etc.)

## Pagination Strategy

Offset/limit (equivalently `page` / `page_size` mapped server-side)

- Use for list endpoints expected to grow (production logs, stock updates, income/expense history)
- Small reference lists may return full `items` without paging in v1 when clearly bounded
- Include `meta.total`, `meta.limit`, and `meta.offset` when paging is used

## Contract Rule

For each feature, document request fields, response fields, validation rules, and error behavior before connecting React or Flutter screens.
