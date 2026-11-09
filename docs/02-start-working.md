# Start Working with Spaces.md (AI-DLC)

This guide walks through the **Farm Management First Release** project using Spaces (`specsmd`) and the AI-DLC agents. It reflects the path taken for intent `001-farm-management-first-release`.

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
├── backend/          # FastAPI + SQLAlchemy + Alembic
├── web/              # React (Vite) + TanStack Query
├── mobile/           # Flutter Clean Architecture
├── docs/
│   ├── 01-install-spaces.md
│   └── 02-start-working.md
├── memory-bank/      # Created/filled by Spaces agents (standards, intents, bolts)
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

---

## 3. Working with the `master-agent`

Begin orchestration:

```text
/specsmd-master-agent
```

Example prompt used for this project:

```text
Read @specs.md and the existing project structure. I’m starting a farm management system with one farm and one owner account. Help me begin the AI-DLC lifecycle. First review the project, identify open decisions, and guide me through the Inception phase. Don’t implement features yet.
```

Outcome: project standards seeded under `memory-bank/standards/`, and the project is ready for **Inception**.

---

## 4. Working with the `inception-agent`

Start (or continue) Inception:

```text
/specsmd-inception-agent intent-create
```

Typical Inception skills for this intent:

- Capture / clarify requirements (FR-1…FR-12)
- System context (single farm, single owner, API + web + mobile)
- Unit decomposition (six vertical slices)
- Bolt plan (API → web → mobile per domain unit)
- Human checkpoints until Construction is approved

### Artifacts produced

```text
memory-bank/
├── bolts/                          # Bolt instances (001…018)
├── intents/
│   └── 001-farm-management-first-release/
│       ├── units/
│       │   ├── 001-platform-and-auth/
│       │   ├── 002-cows/
│       │   ├── 003-poultry/
│       │   ├── 004-crops/
│       │   ├── 005-inventory/
│       │   └── 006-income-expenses/
│       ├── inception-log.md
│       ├── requirements.md
│       ├── system-context.md
│       └── units.md
├── standards/                      # tech-stack, coding-standards, ADRs index, …
└── …
```

### Units and bolt map (this release)

| Unit                    | Bolts       | Stories focus                   |
| ----------------------- | ----------- | ------------------------------- |
| `001-platform-and-auth` | `001`–`003` | Auth API, web auth, mobile auth |
| `002-cows`              | `004`–`006` | Cows API, web, mobile           |
| `003-poultry`           | `007`–`009` | Poultry API, web, mobile        |
| `004-crops`             | `010`–`012` | Crops API, web, mobile          |
| `005-inventory`         | `013`–`015` | Inventory API, web, mobile      |
| `006-income-expenses`   | `016`–`018` | General ledger API, web, mobile |

Within each domain unit, order is always **API → web → mobile**. Hosting / Docker / object storage stayed **out of Construction** (deferred to Operations).

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

1. Platform & auth (`001`–`003`)
2. Cows (`004`–`006`)
3. Poultry (`007`–`009`)
4. Crops (`010`–`012`)
5. Inventory (`013`–`015`)
6. Income & expenses (`016`–`018`)

**Result:** all **18 bolts** are **complete**. Code lives under `backend/`, `web/`, and `mobile/`; bolt artifacts live under `memory-bank/bolts/{bolt-id}/`.

Useful local checks during Construction:

```bash
# Backend
cd backend && python -m pytest

# Web
cd web && npm test -- --run && npm run build

# Mobile
cd mobile && flutter test && flutter analyze
```

Apply Alembic migrations before client smoke tests against a real Postgres DB.

---

## 6. Working with the `operations-agent` (next)

Construction for this intent is finished. **Next phase is Operations.**

```text
/specsmd-operations-agent build-deploy-verify-monitor
```

Expected Operations concerns for this project:

- Build artifacts (backend image/bundle, web static build, mobile build if needed)
- Choose hosting (deferred in Inception open questions)
- Deploy + migrate DB
- Verify smoke paths (sign-up/sign-in, one vertical per domain)
- Monitoring / runbooks as appropriate

Until Operations completes, local development remains the supported run mode (no production host selected yet).

---

## 7. Project status snapshot

| Phase        | Status                                         |
| ------------ | ---------------------------------------------- |
| Inception    | Complete (`001-farm-management-first-release`) |
| Construction | Complete (bolts `001`–`018`)                   |
| Operations   | **Not started** — invoke operations-agent next |

### Code surfaces delivered

| Surface | Stack                | Domains covered                               |
| ------- | -------------------- | --------------------------------------------- |
| Backend | FastAPI `/api/v1`    | Auth, cows, poultry, crops, inventory, ledger |
| Web     | React Vite           | Same domains under protected shell            |
| Mobile  | Flutter + EN/BN l10n | Same domains under authenticated shell        |

### Key deferred decisions (for Operations / later)

- Production hosting and object storage for profile images
- CI signing / store release for mobile
- Any deeper web Bangla localization beyond “where practical”
