# Start Working with Spaces.md

1. Create the iniitial folder structure
2. Start working with `Spaces.md` agent
3. Working with the `construction-agent`
4. Working with the `operations-agent`
5. Working with the `consultant-agent`
6. Working with the `inception-agent`

## 1. Create the initial folder structure

Please create the initial folder structure.

```text
complete_fms/
├── backend/
├── web/
├── mobile/
├── docs/
└── specs/
│   ├── 00-product-brief.md # May be different for different projects
│   ├── 01-architecture.md # May be different for different projects
├── README.md
└── specs.md
```

> Note: The folder structure is not final. It may be different for different projects.
> You can create a folder `specs` and keep all the specs in it, or keep all project specification inside `specs.md` file.

## 2. Start working with `Spaces.md` agent

In Cursor we have the following agents:

- `master-agent`
- `inception-agent`
- `construction-agent`
- `operations-agent`

Here is the detailed description of each agent:

| Name                 | Job                                  | Details                                                                                                                                                                                     |
| -------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `master-agent`       | Orchestrates the AI-DLC workflow     | Tracks project context, routes work to the appropriate specialist, initializes project standards, and answers questions about the workflow. [Details](https://specs.md/agents/master-agent) |
| `inception-agent`    | Plans and defines the work           | Captures intents, clarifies requirements, defines system context, breaks work into units and stories, and plans bolts. [Details](https://specs.md/agents/inception-agent)                   |
| `construction-agent` | Builds and verifies the planned work | Executes bolts through reviewable stages: domain model, technical design, optional ADR, implementation, and testing. [Details](https://specs.md/agents/construction-agent)                  |
| `operations-agent`   | Handles release and operations       | Builds, deploys, verifies, and monitors the system. [Details](https://specs.md/agents/operations-agent)                                                                                     |

## 3. Working with the `master-agent`

Now we can start working with the `master-agent` to orchestrate the AI-DLC lifecycle.

**Begin with:**

```text
/specsmd-master-agent
```

**Tell the agent:**

```text
Read @specs.md and the existing project structure. I’m starting a farm management system with one farm and one owner account. Help me begin the AI-DLC lifecycle. First review the project, identify open decisions, and guide me through the Inception phase. Don’t implement features yet.
```

After the `master-agent` has finished, we have created the initial project structure and the project is in the `Inception phase`.

## 4. Working with the `inception-agent`

You can now start working with the `inception-agent` to start the Inception phase.

```text
/specsmd-inception-agent intent-create
```

After the `inception-agent` has finished, we have the intents for the project. Inside intents, you will find the intents for the project.

```text
memory-bank/
├── bolts/
├── intents/
│   └── 001-farm-management-first-release
│       ├── units
│       │   ├── 001-platform-and-auth
│       │   ├── 002-cows
│       │   ├── 003-poultry
│       │   ├── 004-crops
│       │   ├── 005-inventory
│       │   └── 006-income-expenses
│       ├── inception-log.md
│       ├── requirements.md
│       ├── system-context.md
│       └── units.md
├── operations/
├── standards/
├── ...
```

Now you can start working with the `construction-agent` to start the Construction phase.

## 5. Working with the `construction-agent`

To start working with the `construction-agent`, we need to run the following command:

```text
/specsmd-construction-agent --unit="001-platform-and-auth"
```

After the `construction-agent` has finished, we have the domain model for the project.

Now you can start working with the `operations-agent` to start the Operations phase.

```text
/specsmd-operations-agent build-deploy-verify-monitor
```
