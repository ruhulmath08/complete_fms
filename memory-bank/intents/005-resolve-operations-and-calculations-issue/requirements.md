---
intent: 005-resolve-operations-and-calculations-issue
phase: inception
status: complete
created: '2026-11-13T06:45:00Z'
updated: '2026-11-13T07:00:00Z'
type: enhancement
---

# Requirements: Resolve Operations and Calculations Issue

## Intent Overview

Fix remaining operations and calculation gaps after intents `003`/`004`, and add owner-facing analytics: crop Expenses/Harvests **Action** (edit/delete) parity with cows; inventory **fertilizer-category** stock changes as a full cow-like table; Income & expenses **date-range** numeric totals **plus** a graph; a new **Dashboard** on web and mobile as the post-login landing page with egg production, hen headcount, milk, cow production, expenses/cost, and income graphs; period selectors (day/week/month/year) defaulting to **this week**; **no future dates** validated in the **farm local timezone**. API changes only where required. Applies to **web, mobile, and API**.

## Business Goals

| Goal | Success Metric | Priority |
|------|----------------|----------|
| Crop history maintainability | Farmer edits and deletes at least one crop expense and one harvest on web and on mobile like cow Action | Must |
| Fertilizer stock visibility | All stock changes for items in the fertilizer category display as a paginated Action-capable table like cows | Must |
| Ledger insight | After Apply date range, numeric Total income / Total expenses / Net remain visible and a graph shows the same concepts for the range | Must |
| Dashboard landing & analytics | After login, farmer lands on Dashboard with egg, hen headcount, milk, cow production, expenses/cost, and income graphs for the selected period | Must |
| Period control | Day/week/month/year selection works; default first load is this week; future dates blocked in farm local TZ (UI + API) | Must |
| Developer reuse | Construction extends existing Action/table/pagination/aggregate patterns without inventing one-offs | Should |

## Beneficiaries

- **Farmers (farm owners)** — maintain crop/inventory history; see exact ledger amounts and trends; overview production and money on Dashboard
- **Developers** — clear FR/AC and reuse of `003`/`004` patterns; API only when needed

## Key Outcomes

- Crop Expenses and Harvests are maintainable (edit/delete) on web and mobile
- Fertilizer-category stock history is tabular and operable like cow history
- Ledger shows both exact totals and trend graphs for a date range
- Dashboard is the signed-in home with production + money graphs and safe period selection

## Success Measurement

- Manual/critical-path: farmer completes crop expense+harvest edit/delete on web and mobile
- Fertilizer-category stock table loads and supports cow-parity options on web and mobile
- Ledger apply-range shows numeric totals and an updated graph
- Fresh login lands on Dashboard; default period is this week; future date cannot be chosen; graphs refresh on period change
- Automated tests cover new/changed API contracts and critical client paths

## Concerns

- Correct mapping of fertilizer **category** (not a single item name) across inventory items
- Hen **headcount** series availability vs egg production (two distinct graphs)
- Chart libraries must not break record-keeping if data is empty or slow
- Farm local timezone consistency for “today” / “this week” / future-date rejection

---

## Scope

### In Scope

- **Crops** (web + mobile): Expenses and Harvests — Action Edit (primary) / Delete (danger), confirm delete; API PATCH/DELETE if missing
- **Inventory** (web + mobile): table of **all stock changes for items in the fertilizer category**, with cow-like table options (pagination, columns, Action as applicable); API filter/list support if required
- **Income & expenses** (web + mobile): keep numeric Total income, Total expenses, Net; add graph below Apply date range for the same three concepts over the range
- **Dashboard** (web + mobile): new page; post-login landing; graphs for **egg production**, **hen headcount**, **milk**, **cow production**, **expenses/cost**, **income**; period day/week/month/year; default **this week**; future dates blocked in **farm local timezone**
- **API**: mutations/aggregates only as needed for the above; owner-scoped
- Tests; mobile EN/BN strings for new UI

### Out of Scope

- Reopening intents `003`/`004` wholesale
- Multi-farm, staff roles, forecasting engines
- Soft-delete (hard-delete only)
- Full BI beyond specified graphs
- Auth product changes beyond landing redirect to Dashboard
- Non-fertilizer inventory category redesign (other categories unchanged unless required for shared table component)

---

## Functional Requirements

### FR-1: Crop expenses Action (edit/delete)

- **Description**: Crop Expenses history tables on web and mobile support Edit and Delete using the same Action conventions as cow milk/feeding (Edit primary, Delete danger, confirm before delete). API provides owner-scoped PATCH/DELETE when not already present.
- **Acceptance Criteria**:
  - Farmer can edit an expense row and see updated values on web and on mobile
  - Farmer can delete an expense row after confirmation on web and on mobile
  - Unauthorized or wrong-owner access is rejected by API
- **Priority**: Must

### FR-2: Crop harvests Action (edit/delete)

- **Description**: Crop Harvests history tables on web and mobile support Edit and Delete with the same Action conventions as cows. API provides owner-scoped PATCH/DELETE when not already present.
- **Acceptance Criteria**:
  - Farmer can edit a harvest row and see updated values on web and on mobile
  - Farmer can delete a harvest row after confirmation on web and on mobile
  - Unauthorized or wrong-owner access is rejected by API
- **Priority**: Must

### FR-3: Fertilizer-category stock changes table

- **Description**: Inventory surfaces a table of **all stock updates for inventory items whose category is fertilizer** (fertilizer category, not a single “Fertilizer for soil” item name), with options parity to cow history tables (pagination, columns, Action/edit-delete as applicable to stock updates).
- **Acceptance Criteria**:
  - On web and mobile, stock changes for fertilizer-category items appear in a tabular history UI
  - Table supports the same class of list options as cow history (at minimum pagination and readable columns; Action if stock updates support mutation in this intent)
  - Non-fertilizer categories are not required to change behavior beyond shared components
- **Priority**: Must

### FR-4: Ledger numeric totals plus range graph

- **Description**: On Income & expenses, after Apply date range, the UI keeps **numeric** Total income, Total expenses, and Net, and also shows a **graph** of income, expenses, and net for that range (below the apply control). Applies to web and mobile.
- **Acceptance Criteria**:
  - Applying a valid range updates numeric Total income, Total expenses, and Net
  - The same apply updates a graph that reflects income, expenses, and net for that range
  - Empty ranges show zero/empty-safe numeric values and graph without crashing
- **Priority**: Must

### FR-5: Dashboard page and post-login landing

- **Description**: Web and mobile provide a Dashboard page. Successful sign-in navigates to Dashboard (replacing prior home-first landing). Dashboard is reachable from app shell/nav.
- **Acceptance Criteria**:
  - After successful login on web, farmer lands on Dashboard
  - After successful login on mobile, farmer lands on Dashboard
  - Signed-in navigation can open Dashboard without signing out
- **Priority**: Must

### FR-6: Dashboard production and money graphs

- **Description**: Dashboard displays graphs for: **egg production**, **hen headcount**, **milk production**, **cow production**, **expenses/cost**, and **income** for the selected period.
- **Acceptance Criteria**:
  - Each of the six series areas is present on Dashboard for web and mobile
  - Egg production and hen headcount are distinct graphs/series
  - Empty or zero data shows empty/zero-safe UI without uncaught errors
- **Priority**: Must

### FR-7: Dashboard period selection, default week, no future dates

- **Description**: Farmer selects period granularity day / week / month / year. First load defaults to **this week**. Date selection and API bounds reject **future** calendar dates relative to the **farm’s local timezone**.
- **Acceptance Criteria**:
  - Default period on first Dashboard load is this week (farm local TZ)
  - Changing day/week/month/year refreshes dashboard graphs
  - UI prevents selecting a future date in farm local TZ
  - Aggregate/dashboard API rejects requests whose end bound is after “today” in farm local TZ
- **Priority**: Must

### FR-8: API support only as needed

- **Description**: Backend changes exist only to support crop expense/harvest mutations, fertilizer-category stock listing/mutations as required, ledger graph series if not client-derivable, and dashboard aggregates. Owner-scoped JWT rules unchanged.
- **Acceptance Criteria**:
  - Every new or changed endpoint maps to FR-1–FR-7
  - Mutations and aggregates enforce owner scope
  - No unrelated API surface area ships in this intent
- **Priority**: Must

---

## Non-Functional Requirements

### NFR-1: Performance

| Requirement | Metric | Target |
|-------------|--------|--------|
| Dashboard aggregates | Time to usable graph data for modest farm datasets | p95 &lt; 3s preferred; must complete within existing client timeouts |
| History Action | Edit/delete round-trip | Same class as existing cow/poultry Action |
| Ledger apply | Totals + graph refresh | Completes within existing client timeouts |

### NFR-2: Security

| Requirement | Standard | Notes |
|-------------|----------|-------|
| Authentication / ownership | Existing JWT owner scope | Dashboard, ledger, crop, inventory APIs owner-only |
| Future-date rejection | Server validation in farm local TZ | Do not rely on UI alone |

### NFR-3: Reliability

| Requirement | Metric | Target |
|-------------|--------|--------|
| Empty / sparse data | Graphs and tables | Empty or zero-safe states; no uncaught client errors |
| Chart failure isolation | Record-keeping flows | Crop/inventory/ledger CRUD remains usable if a chart fails to render |

### NFR-4: Usability / i18n

| Requirement | Metric | Target |
|-------------|--------|--------|
| Action colors | Convention | Edit = primary; Delete = danger |
| Mobile strings | Locales | EN + BN for new Dashboard/ledger/crop/inventory UI copy |
| Landing clarity | Navigation | Dashboard labeled and discoverable in shell |

---

## Constraints

### Technical Constraints

**Project-wide standards**: Loaded from memory-bank standards by Construction Agent (do not duplicate here).

**Intent-specific**:

- Reuse cow/poultry Action + history table patterns from intents `003`/`004`
- Fertilizer scope = **inventory category fertilizer**, all stock changes for items in that category
- Charts on React and Flutter; graceful empty/error if chart layer fails
- Landing route / redirect updated on web and mobile
- Farm local timezone is the source of truth for “today”, “this week”, and future-date checks (use farm settings timezone if present; otherwise document Construction default)

### Business Constraints

- Single farm, single owner
- No new domains beyond specified Dashboard analytics
- No hard regulatory deadline stated for this intent

---

## Assumptions

| Assumption | Risk if Invalid | Mitigation |
|------------|-----------------|------------|
| Inventory already has a fertilizer category enum/value usable for filtering | Cannot filter stock rows | Confirm category value in Construction; add if missing via FR-8 |
| Hen headcount can be derived from poultry group records (or a clear aggregate) over the period | Missing graph | Define aggregate rule in API design; if impossible, spike then adjust scope |
| Cow production means milk and/or cow-related production series distinct from “milk” labeling | Duplicate graphs | Clarify series definitions in technical design (milk qty vs cow count/output) |
| Farm timezone is available or defaultable (e.g. from farm settings / profile) | Wrong “today” | Construction documents default TZ if unset |
| Ledger period totals can feed or accompany time-series points for the graph | Wrong chart shape | Prefer dedicated series endpoint if totals-only is insufficient |

---

## Open Questions

| Question | Owner | Due Date | Resolution |
|----------|-------|----------|------------|
| Exact meaning of “Fertilizer for soil” | Product owner | Checkpoint 1 | **Resolved**: all stock changes for items in the **fertilizer category** |
| Hen on dashboard | Product owner | Checkpoint 1 | **Resolved**: egg production graph **and** hen **headcount** graph |
| Ledger numeric vs graph | Product owner | Checkpoint 1 | **Resolved**: keep **numeric totals and graph** |
| Default dashboard period | Product owner | Checkpoint 1 | **Resolved**: **this week** |
| Future date timezone | Product owner | Checkpoint 1 | **Resolved**: **farm local timezone** |
| Exact definition of “cow production” vs “milk” series (qty vs headcount vs other) | Product owner | Checkpoint 2 / design | Pending |
| Farm timezone source when settings unset | Construction | Design | Pending default |
