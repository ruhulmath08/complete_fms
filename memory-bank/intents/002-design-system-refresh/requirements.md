---
intent: 002-design-system-refresh
phase: inception
status: complete
created: '2026-11-11T17:37:14Z'
updated: '2026-11-11T18:10:21Z'
type: enhancement
---

# Requirements: Design System Refresh

## Intent Overview

Refresh the visual design and UX of the Farm Management System across the **React (Vite) web app** and **Flutter mobile app** — look & feel, layout, and components — with shared design tokens/components where practical. Web navigation moves to a collapsible left sidebar; mobile lists use card layouts; cow create/detail flows gain image and auto tag-number rules; milk and feeding history display as paginated tables. API contract changes are in scope when required to support these UI behaviors.

## Business Goals

| Goal                               | Success Metric                                                                               | Priority |
| ---------------------------------- | -------------------------------------------------------------------------------------------- | -------- |
| Cohesive web app shell             | Signed-in web app shows left sidebar (show/hide), header, and footer with specified branding | Must     |
| Clear data presentation            | Primary list/history views use tables on web and cards on mobile where specified             | Must     |
| Cow create UX                      | Add-cow page includes cow image; tag number auto-generated; weight labeled Weight (kg)       | Must     |
| Preserve first-release workflows   | Auth, cows, poultry, crops, inventory, income/expenses remain usable after the refresh       | Must     |
| Practical shared design foundation | Shared tokens (e.g. primary green `#2f6a3a`, white text on menu) applied where practical     | Should   |

---

## Scope

### In Scope

- React web UI refresh: left menubar, header, footer, tables, cow page updates
- Flutter mobile UI refresh: card views for list items; aligned chrome where practical
- Shared design tokens/components where practical (menu green `#2f6a3a`, white menu text)
- API contract / behavior changes required by the new UI (auto tag number, pagination for milk/feeding, cow image if stored via API)
- Notification icon and profile image in the web header (top right)

### Out of Scope

- New farm domains (reports/dashboards, multi-farm, staff/roles, animal health as a domain)
- Full push-notification backend unless product owner later specifies it (icon may be UI-only initially)
- Backend business-rule rewrites unrelated to UI support
- Full product rebrand (name/identity) unless explicitly added later

---

## Functional Requirements

### FR-1: Web app shell — left sidebar, header, footer

- **Description**: On the signed-in React web app, primary navigation (Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings) appears as a **left-side menubar** (not a top-only nav). The menu background is `#2f6a3a` with **white** text. The menu can be **shown and hidden** (collapse/expand). The shell includes a **header** and a **footer**. In the header **top-right**, show a **notification icon** and the **user profile image**.
- **Acceptance Criteria**:
  - All listed nav destinations are reachable from the left menubar
  - Menubar background is `#2f6a3a` and menu text/icons are white (or clearly readable white/light on that green)
  - Owner can show and hide the menubar
  - Header and footer are present on signed-in pages using the shell
  - Header top-right shows a notification icon and the signed-in owner's profile image (fallback avatar if image missing)
  - Notification icon may open an empty/placeholder state until notification data is specified
- **Priority**: Must
- **Related Stories**: TBD

### FR-2: Mobile list items as cards

- **Description**: On Flutter mobile, primary entity list screens present items in a **card** layout (not a dense plain list-only style), consistent with the refreshed design.
- **Acceptance Criteria**:
  - Cow, poultry, crops, inventory, and income/expenses list screens use card-style rows/cards for each item
  - Cards remain tappable to open detail/create flows already in first release
- **Priority**: Must
- **Related Stories**: TBD

### FR-3: Add cow page — cow image and field labels

- **Description**: The add-cow page includes a **cow image** (upload or selectable image area). The weight field is labeled **Weight (kg)**.
- **Acceptance Criteria**:
  - Add-cow UI shows a cow image control (preview + choose/upload as supported by platform)
  - Weight field label reads exactly **Weight (kg)** (or localized equivalent that includes kg)
  - If the image is persisted, API/storage supports associating the image with the cow record; if client-only placeholder is chosen later, that decision is recorded in inception
- **Priority**: Must
- **Related Stories**: TBD

### FR-4: Cow tag number auto-generation

- **Description**: Cow **tag number is auto-generated** and not manually invented by the owner. Format: `{name}{breed}{6 random digits}` (name + breed + six random digits). Generation occurs on create (and regenerates only if product owner later allows edit rules — default: set at create, displayed read-only afterward unless edit is explicitly allowed).
- **Acceptance Criteria**:
  - On successful create, `tag_number` matches name + breed + exactly 6 digits
  - Owner does not need to type a custom tag number on create (field is generated by system)
  - Name and breed required for generation (or generation waits until both are provided before submit)
  - Duplicate generated tags are rejected or retried until unique within the owner's cows
  - API (or agreed client+API contract) enforces or returns the generated tag consistently for web and mobile
- **Priority**: Must
- **Related Stories**: TBD

### FR-5: Milk production — paginated Bootstrap table (web)

- **Description**: On web, cow milk production history is displayed as a **Bootstrap table** with columns: **No**, **date+time**, **unit price**, **total**, **note**. The table shows **10 rows per page** with **pagination**. Include quantity (and unit if stored) as needed so **total** is understandable (e.g. quantity × unit price = total) even if quantity is an additional column.
- **Acceptance Criteria**:
  - Milk history on web uses a Bootstrap table
  - Columns include at least: No (row index), date+time, unit price, total, note
  - Default page size is 10; pagination controls move between pages
  - Empty and error states are clear
  - API supports page size 10 (offset/limit or page/page_size) for milk list if not already adequate
- **Priority**: Must
- **Related Stories**: TBD

### FR-6: Feeding — paginated table (web)

- **Description**: On web, cow feeding history is displayed as a table with the **same pagination pattern as milk** (10 rows per page + pagination). Prefer Bootstrap table styling consistent with milk.
- **Acceptance Criteria**:
  - Feeding history on web uses a table layout consistent with milk
  - Default page size is 10 with pagination
  - Columns cover the feeding fields needed to understand each entry (at minimum date+time, feed type/name, quantity, unit, note — align with first-release data)
  - API pagination matches milk list pattern where applicable
- **Priority**: Must
- **Related Stories**: TBD

### FR-7: Prefer tables for tabular data on web

- **Description**: Where data is naturally tabular (lists of records with repeated columns), the web app **displays data as tables** under the refreshed design, not only for milk/feeding.
- **Acceptance Criteria**:
  - Web list/history views for cows and related sub-records prefer table layouts where columns are clear
  - Tables remain usable on typical desktop widths; horizontal scroll allowed if necessary for narrow viewports
- **Priority**: Should
- **Related Stories**: TBD

### FR-8: API contract updates for UI support

- **Description**: Backend/API is updated as needed for auto tag generation, milk/feeding pagination (page size 10), and cow image association if images are stored server-side. Product owner may add further contract changes during this intent.
- **Acceptance Criteria**:
  - Documented API behavior matches web and mobile clients for tag generation, pagination, and image fields used by UI
  - Breaking changes are versioned or coordinated so both clients stay in sync
  - No unrelated domain API rewrites
- **Priority**: Must
- **Related Stories**: TBD

### FR-9: Shared design tokens / components (practical)

- **Description**: Extract shared visual tokens (at least primary menu green `#2f6a3a`, white-on-green menu text, spacing/typography used by shell) and reuse components (shell header, footer, sidebar, tables, cards) where practical across web; mirror token values on mobile where practical.
- **Acceptance Criteria**:
  - Menu green and white text are not hard-coded in many one-off places without a shared token/variable
  - Shell pieces (sidebar/header/footer) are reusable across signed-in routes
- **Priority**: Should
- **Related Stories**: TBD

---

## Non-Functional Requirements

### NFR-1: Usability

- **Metric**: Signed-in owner can open any primary nav destination from the left menubar in ≤ 2 clicks from the shell
- **Target**: Met on web after refresh
- **Notes**: Mobile uses existing nav patterns plus card lists

### NFR-2: Consistency

- **Metric**: Menu brand color `#2f6a3a` and white menu text appear on all signed-in shell pages; milk and feeding tables share the same pagination default (10)
- **Target**: 100% of shell pages; milk + feeding lists

### NFR-3: Compatibility

- **Metric**: First-release workflows remain completable on web and mobile after UI refresh
- **Target**: No blocking regressions on auth, cows, poultry, crops, inventory, income/expenses happy paths

### NFR-4: Performance (list pagination)

- **Metric**: Milk and feeding list requests use page size 10; UI does not require loading the entire history to show the first page
- **Target**: First page usable without full-history download

### NFR-5: Security

- **Metric**: Profile image and cow image (if stored) respect existing auth; private images not served without authorization
- **Target**: Same auth model as first release; no anonymous access to private media

---

## Constraints

### Technical Constraints

**Project-wide standards**: Required standards will be loaded from memory-bank standards folder by Construction Agent

**Intent-specific constraints**:

- Builds on `001-farm-management-first-release` (brown-field UI refresh)
- Web stack remains React (Vite); use Bootstrap table styling for milk (and aligned tables for feeding)
- Prefer shared tokens/components only where practical — web and mobile need not be identical layouts
- No additional constraints stated by product owner for timeline/regulatory (Checkpoint 1 item 3 left blank)

### Business Constraints

- Beneficiaries: farm owners (end-user experience) and developers (maintainable UI)
- Notification feature may be chrome-only until a notification data source is specified

---

## Assumptions

| Assumption                                                                                                                      | Risk if Invalid                    | Mitigation                                   |
| ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | -------------------------------------------- |
| Checkpoint 1 items 3–5 blank means no extra timeline/regulatory constraints; success = FRs above met; no top concern called out | Hidden deadline or compliance miss | Confirm at Checkpoint 2                      |
| Tag format is concatenation of name + breed + 6 digits without separators unless owner specifies otherwise                      | Tags hard to read                  | Confirm separator rules at review            |
| “Total” for milk = quantity × unit price (quantity may appear as extra column)                                                  | Wrong total definition             | Confirm at Checkpoint 2                      |
| Notification icon is UI placeholder until notification API/content is defined                                                   | Expectation of real alerts         | Explicit out-of-scope for backend alerts     |
| Cow image is in scope for add-cow; persistence via API preferred if storage pattern already exists for profile images           | Client-only mock image             | Decide in construction if upload path needed |

---

## Open Questions

| Question                                                    | Owner         | Due Date     | Resolution            |
| ----------------------------------------------------------- | ------------- | ------------ | --------------------- |
| Tag format separators (none vs `-`)?                        | Product owner | Checkpoint 2 | Pending               |
| Exact milk table columns: include quantity/unit explicitly? | Product owner | Checkpoint 2 | Pending               |
| Is notification icon placeholder-only for this intent?      | Product owner | Checkpoint 2 | Pending               |
| Cow image: required on create, or optional?                 | Product owner | Checkpoint 2 | Pending               |
| Apply left sidebar + header/footer to all signed-in pages?  | Product owner | Checkpoint 2 | Assumed yes           |
| Any timeline or other constraints (Checkpoint 1 #3–5)?      | Product owner | Checkpoint 2 | Pending (none stated) |
