# Start Working with Spaces.md (AI-DLC)

This guide walks through the **Farm Management System** (`complete_fms`) using Spaces (`specsmd`) and the AI-DLC agents. It reflects the full path taken across intents `001`–`005` (bolts `001`–`034`): first-release domains, design refresh, production UX, poultry history actions, and Dashboard / ops-calc.

Package runbooks: [root README](../README.md), [backend](../backend/README.md), [web](../web/README.md), [mobile](../mobile/README.md).

## Table of contents

1. [Create the initial folder structure](#1-create-the-initial-folder-structure)
2. [Spaces.md agents](#2-spacesmd-agents)
3. [Master agent](#3-working-with-the-master-agent)
4. [Inception agent](#4-working-with-the-inception-agent)
5. [Construction agent](#5-working-with-the-construction-agent)
6. [Operations agent (next)](#6-working-with-the-operations-agent-next)
7. [Project status snapshot](#7-project-status-snapshot)

---

## 1. Create the initial folder structure

Create a working tree similar to:

```text
complete_fms/
├── backend/          # FastAPI + SQLAlchemy + Alembic (+ scripts/seed_demo_data.py)
├── web/              # React (Vite) + TanStack Query
├── mobile/           # Flutter Clean Architecture (EN/BN)
├── docs/
│   ├── 01-install-spaces.md
│   └── 02-start-working.md
├── memory-bank/      # Standards, intents, bolts, local ops notes
├── specs/
│   ├── 00-product-brief.md
│   └── 01-architecture.md
├── README.md
└── specs.md
```

> The exact layout can vary. Specs may live in `specs/` or a single `specs.md`. Install Spaces first: see [01-install-spaces.md](./01-install-spaces.md).

---

## 2. Spaces.md agents

| Name                 | Job                                  | Details                                                                                                                                                                                     |
| -------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `master-agent`       | Orchestrates the AI-DLC workflow     | Tracks project context, routes work to the appropriate specialist, initializes project standards, and answers questions about the workflow. [Details](https://specs.md/agents/master-agent) |
| `inception-agent`    | Plans and defines the work           | Captures intents, clarifies requirements, defines system context, breaks work into units and stories, and plans bolts. [Details](https://specs.md/agents/inception-agent)                   |
| `construction-agent` | Builds and verifies the planned work | Executes bolts through reviewable stages (DDD or simple). [Details](https://specs.md/agents/construction-agent)                                                                             |
| `operations-agent`   | Handles release and operations       | Builds, deploys, verifies, and monitors the system. [Details](https://specs.md/agents/operations-agent)                                                                                     |

AI-DLC phases: **Inception → Construction → Operations**.

Repeat **Inception → Construction** for each new intent. Do not reopen a sealed intent; create the next numbered intent instead (as with `004` after `003`).

---

## 3. Working with the `master-agent`

Begin orchestration:

```text
/specsmd-master-agent
```

Example prompt used at project start:

```text
Read @specs.md and the existing project structure. I’m starting a farm management system with one farm and one owner account. Help me begin the AI-DLC lifecycle. First review the project, identify open decisions, and guide me through the Inception phase. Don’t implement features yet.
```

Outcome: project standards seeded under `memory-bank/standards/`, and the project is ready for **Inception**.

Later, use Master to route (“next intent?”, “which agent?”, “are we ready for Operations?”) without implementing features itself.

---

## 4. Working with the `inception-agent`

Start a new intent (or continue one):

```text
/specsmd-inception-agent intent-create
```

Typical Inception skills:

- Capture / clarify requirements (Checkpoint 1–2)
- System context (single farm, single owner, API + web + mobile)
- Unit decomposition (often **API → web → mobile** layers for enhancements)
- Stories + bolt plan
- Review checkpoints until Construction is approved

### Artifacts layout

```text
memory-bank/
├── bolts/                          # Bolt instances (001…034)
├── intents/
│   ├── 001-farm-management-first-release/
│   ├── 002-design-system-refresh/
│   ├── 003-update-api-web-and-mobile-design/
│   ├── 004-poultry-history-actions-and-table-polish/
│   └── 005-resolve-operations-and-calculations-issue/
│       ├── units/
│       ├── inception-log.md
│       ├── requirements.md
│       ├── system-context.md
│       └── units.md
├── operations/                     # Local build/deploy notes when started
├── standards/                      # tech-stack, coding-standards, UX, API, …
└── …
```

### Intents completed (this project)

| Intent                                          | Focus                                                                                      | Bolts       |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------- |
| `001-farm-management-first-release`             | Auth + domain record keeping (cows, poultry, crops, inventory, ledger) on API, web, mobile | `001`–`018` |
| `002-design-system-refresh`                     | Shell, tokens, cow image/auto-tag, milk/feeding tables                                     | `019`–`023` |
| `003-update-api-web-and-mobile-design`          | Production-ready UX: universal tables, totals, Action edit/delete, mobile drawer           | `024`–`028` |
| `004-poultry-history-actions-and-table-polish`  | Poultry egg/feeding PATCH/DELETE + UI; history column `#` → **No.**                        | `029`–`031` |
| `005-resolve-operations-and-calculations-issue` | Crop history Action, fertilizer stock table, ledger graph, **Dashboard**                   | `032`–`034` |

### Units and bolt map — intent `001`

| Unit                    | Bolts       | Stories focus                   |
| ----------------------- | ----------- | ------------------------------- |
| `001-platform-and-auth` | `001`–`003` | Auth API, web auth, mobile auth |
| `002-cows`              | `004`–`006` | Cows API, web, mobile           |
| `003-poultry`           | `007`–`009` | Poultry API, web, mobile        |
| `004-crops`             | `010`–`012` | Crops API, web, mobile          |
| `005-inventory`         | `013`–`015` | Inventory API, web, mobile      |
| `006-income-expenses`   | `016`–`018` | General ledger API, web, mobile |

### Units and bolt map — intents `002`–`005` (layer slices)

| Intent | Units                                                                              | Bolts                           |
| ------ | ---------------------------------------------------------------------------------- | ------------------------------- |
| `002`  | `001-design-api`, `002-design-web`, `003-design-mobile`                            | `019`; `020`–`021`; `022`–`023` |
| `003`  | `001-design-api`, `002-design-web`, `003-design-mobile`                            | `024`; `025`–`026`; `027`–`028` |
| `004`  | `001-poultry-actions-api`, `002-poultry-actions-web`, `003-poultry-actions-mobile` | `029`; `030`; `031`             |
| `005`  | `001-ops-calc-api`, `002-ops-calc-web`, `003-ops-calc-mobile`                      | `032`; `033`; `034`             |

Within each enhancement, order stayed **API → web → mobile**. Hosting / Docker / object storage stayed **out of Construction** (deferred to Operations).

---

## 5. Working with the `construction-agent`

Start Construction on a unit:

```text
/specsmd-construction-agent --unit="001-platform-and-auth"
```

Then continue unit by unit (or pass `--bolt-id` when resuming a specific bolt).

### Bolt types used

| Type                       | When used            | Stages (high level)                                                 |
| -------------------------- | -------------------- | ------------------------------------------------------------------- |
| `ddd-construction-bolt`    | API / domain modules | Domain model → Technical design → ADR (optional) → Implement → Test |
| `simple-construction-bolt` | Web and mobile UI    | Plan → Implement → Test                                             |

At each stage checkpoint, **approve** (or request changes) before the agent advances. Commit and push completed bolts as you go so progress is durable.

### How this project ran Construction

**Intent `001` — first release**

1. Platform & auth (`001`–`003`)
2. Cows (`004`–`006`)
3. Poultry (`007`–`009`)
4. Crops (`010`–`012`)
5. Inventory (`013`–`015`)
6. Income & expenses (`016`–`018`)

**Intent `002` — design refresh** — bolts `019`–`023`  
**Intent `003` — production UX** — bolts `024`–`028`  
**Intent `004` — poultry actions + No. column** — bolts `029`–`031`  
**Intent `005` — ops/calc + Dashboard** — bolts `032`–`034`

**Result:** all **34 bolts** are **complete**. Code lives under `backend/`, `web/`, and `mobile/`; bolt artifacts live under `memory-bank/bolts/{bolt-id}/`.

Useful local checks during Construction:

```bash
# Backend
cd backend && python -m pytest

# Web
cd web && npm test && npm run build

# Mobile
cd mobile && flutter test && flutter analyze
```

Apply Alembic migrations before client smoke tests against a real Postgres DB. Optional demo farm:

```bash
cd backend && source .venv/bin/activate
python scripts/seed_demo_data.py          # or --reset
# demo@completefms.com / Password1
```

---

## 6. Working with the `operations-agent` (next)

Product Construction for intents `001`–`005` is finished. **Production-oriented Operations is still the next major phase.**

```text
/specsmd-operations-agent build-deploy-verify-monitor
```

Expected Operations concerns:

- Build artifacts (backend image/bundle, web static build, mobile build if needed)
- Choose hosting (deferred in early Inception open questions)
- Deploy + migrate DB
- Verify smoke paths (sign-up/sign-in, Dashboard period charts, one vertical per domain including Action edit/delete)
- Monitoring / runbooks as appropriate

Local-only notes already exist under `memory-bank/operations/` for some intents (e.g. poultry polish). Until full Operations completes, **local development** remains the supported run mode (no production host selected yet).

---

## 7. Project status snapshot

| Phase        | Status                                                        |
| ------------ | ------------------------------------------------------------- |
| Inception    | Complete for intents `001`–`005`                              |
| Construction | Complete (bolts `001`–`034`)                                  |
| Operations   | **Not started** for production — invoke operations-agent next |

### Code surfaces delivered

| Surface | Stack             | Domains / capabilities                                                                                      |
| ------- | ----------------- | ----------------------------------------------------------------------------------------------------------- |
| Backend | FastAPI `/api/v1` | Auth, cows (+ image), poultry, crops, inventory, ledger, **dashboard** aggregates                           |
| Web     | React Vite        | Same domains; Dashboard landing; history tables with **Total**, Action, **No.**; ledger + fertilizer tables |
| Mobile  | Flutter + EN/BN   | Same domains; drawer shell; Dashboard; Action parity; full profile image preview                            |

### Key deferred decisions (for Operations / later)

- Production hosting and object storage for profile / cow images
- CI signing / store release for mobile
- Any deeper web Bangla localization beyond “where practical”
- Production monitoring and runbooks beyond local ops notes
