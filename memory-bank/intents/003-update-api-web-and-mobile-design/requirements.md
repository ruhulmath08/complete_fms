---
intent: 003-update-api-web-and-mobile-design
phase: inception
status: complete
created: '2026-11-12T06:32:03Z'
updated: '2026-11-12T08:36:33Z'
type: enhancement
---

# Requirements: Update API, Web, and Mobile Design

## Intent Overview

Completely update the web and mobile design of the Farm Management System so the experiences are **production ready**. Identify and fix design issues that block developers and farm owners from using the products effectively. Update the API only where required to support the redesigned web and mobile experiences. Builds on `001-farm-management-first-release` and `002-design-system-refresh` (shell, tokens, cow tables/cards, auto-tag, cow image) without redoing that work unless it still fails the production-ready bar.

## Business Goals

| Goal                                   | Success Metric                                                                                               | Priority |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ | -------- |
| Production-ready web and mobile design | Farm owners complete core domain workflows on web and mobile without design blockers                         | Must     |
| Consistent, easy-to-use product        | Shared tokens, shell patterns, list/detail states, and form patterns feel like one product across clients    | Must     |
| Developer-usable design foundation     | Developers can add or extend screens using shared layout/state/components without inventing one-off patterns | Must     |
| API support only as needed             | API changes exist only when required by the redesigned clients                                               | Must     |

---

## Scope

### In Scope

- Redesign the web and mobile experiences so they’re production ready
- Identify and fix design issues that block developers and farm owners from using the products effectively
- Update the API only where needed to support the redesigned web and mobile experiences
- Align with `memory-bank/standards/ux-guide.md` (tokens, practical a11y, responsive web, BN/EN on mobile)
- Universal paginated data tables (milk-production pattern) across the application
- Row **Total** columns where a total is meaningful (including cow Feeding); API support as needed
- Per-row **Action** column (Edit / Delete icons) on data tables after records exist; API update/delete as needed
- **Mobile parity (Must)**: Flutter cow milk and feeding histories show **Total** (and feeding **unit cost**), plus **Edit/Delete** actions wired to the same API as web—not web-only
- **Mobile navigation (Must)**: Landing/signed-in shell uses a **navigation drawer** for Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings; TitleBar shows a **three-dot** overflow with Profile and Logout (icon+title); Logout opens a confirm/cancel alert dialog
- Cow detail layout: rectangular image on the left, info on the right (web and mobile)
- Remove in-page “← Back to …” links; refresh **Edit** and **Archive** button treatment

### Out of Scope

- API changes unrelated to the design update
- New features or user groups beyond what’s needed to support developers and farm owners
- Backend or infrastructure changes that don’t directly address a design requirement
- Full formal WCAG audit as a release gate
- New farm domains (reports/dashboards, multi-farm, staff/roles, animal health) unless required only as a design shell destination

---

## Functional Requirements

### FR-1: Production-ready visual system (web + mobile)

- **Description**: Establish and apply a single production-ready visual system across web and mobile: color, typography, spacing, elevation/surface, and interactive states (default, hover/press where applicable, focus, disabled). Intent `002` tokens are the baseline; extend or correct them where they still feel incomplete or inconsistent with `ux-guide.md`.
- **Acceptance Criteria**:
  - Shared token set exists on web (CSS variables) and mobile (`AppTokens` / ThemeData) covering at least color, typography, and spacing
  - Primary brand green `#2f6a3a` (or documented successor) and readable on-brand contrast remain consistent on both clients
  - Display and body typography read as one product family across web and mobile (mobile mirrors web display/body roles, not necessarily identical font files)
  - One-off hard-coded colors/spacing on primary signed-in screens are replaced by tokens except documented exceptions
- **Priority**: Must
- **Related Stories**: TBD

### FR-2: Web signed-in shell polish (responsive + accessible)

- **Description**: Make the existing web left-sidebar shell production-ready on desktop and narrow viewports: collapse/expand behavior, overlay/drawer behavior on small screens, header (notification + profile), and footer remain usable with keyboard and clear focus.
- **Acceptance Criteria**:
  - All primary nav destinations remain reachable from the left menubar
  - At ≤800px (or documented breakpoint), open sidebar uses a backdrop/scrim; content behind the drawer is not interactable while open
  - Escape (or equivalent) closes the mobile drawer; focus returns to the control that opened it
  - Header notification and profile controls are keyboard reachable; Escape closes open popovers/menus
  - Visible `:focus-visible` styles exist for primary interactive chrome (nav items, buttons, header controls)
  - Skip link to main content is present on signed-in shell pages
- **Priority**: Must
- **Related Stories**: TBD

### FR-3: Mobile navigation chrome refresh

- **Description**: Replace the crowded multi-`TextButton` mobile `AppBar` navigation with a **navigation drawer** on the signed-in landing/shell, plus a TitleBar **three-dot (⋮) overflow** for Profile and Logout. Drawer destinations: **Cows**, **Poultry**, **Crops**, **Inventory**, **Income & expenses**, **Profile**, **Farm settings**.
- **Acceptance Criteria**:
  - Signed-in landing/shell presents a **navigation drawer** listing exactly: Cows, Poultry, Crops, Inventory, Income & expenses, Profile, Farm settings (labels may be localized BN/EN)
  - Drawer items are tappable and navigate to the corresponding screens; active destination is visually indicated
  - TitleBar (AppBar) shows a **three-dot icon** on the **right**
  - Tapping the three-dot icon opens a menu/list of items each showing **icon + title** for **Profile** and **Logout**
  - Choosing **Profile** navigates to the profile screen
  - Choosing **Logout** opens an **alert dialog** with a clear **title**, **message**, **Confirm** (or equivalent affirmative) button, and **Cancel** button
  - Confirming logout signs the owner out; Cancel dismisses the dialog without signing out
  - No horizontal overflow of crowded TextButton destinations in the AppBar
  - Navigation chrome uses shared tokens (FR-1)
- **Priority**: Must
- **Related Stories**: `001-mobile-nav-chrome`

### FR-4: Shared page layout and universal data tables (web)

- **Description**: Introduce reusable web page/list layout primitives and make **display data tables the default** across the application, matching the **Milk production** table pattern on the cow detail page (Bootstrap-style table + pagination). Apply to primary entity lists (cows, poultry, crops, inventory, income/expenses) and in-page history/sub-record tables (including Feeding and other tabular histories).
- **Acceptance Criteria**:
  - A documented shared list/page layout component or CSS pattern is used by the five primary entity list screens
  - All primary entity list screens and tabular history/sub-record views render as paginated tables in the Milk production style (not card-only lists for tabular data)
  - Default page size matches Milk production (**10** rows per page) unless product owner documents an exception
  - Primary action (e.g. Add) placement is consistent across list screens
  - Developers can create a new list/history table by composing the shared pattern without copying a full page scaffold
- **Priority**: Must
- **Related Stories**: TBD

### FR-5: Shared empty, loading, and error states (web + mobile)

- **Description**: Provide shared empty, loading, and error UI primitives on web and mobile, and adopt them on primary list and detail screens so farm owners always get clear feedback and developers do not invent one-off muted `<p>` / red `Text` patterns.
- **Acceptance Criteria**:
  - Web: shared loading, empty, and error components (error may extend existing `ErrorBanner`); empty states include short message and optional primary CTA when an add action exists
  - Mobile: shared loading, empty, and error widgets; empty states include short localized message and optional primary action
  - Async updates that replace content announce errors accessibly on web (`role="alert"` or `aria-live` as appropriate)
  - Primary entity list screens on both clients use the shared primitives
- **Priority**: Must
- **Related Stories**: TBD

### FR-6: List pagination parity for production scale (web + mobile)

- **Description**: Every data table that can grow beyond one page uses pagination like Milk production (page size 10 + controls), including primary entity lists and history tables. Fix silent truncation (web lists capped at 100 with no UI; mobile milk/feeding first page only).
- **Acceptance Criteria**:
  - Web primary lists for cows, poultry, crops, inventory, and income/expenses support pagination controls when total exceeds page size (default **10**, parity with milk)
  - Web cow milk and feeding tables retain/extend paginated behavior from intent `002`
  - Mobile cow milk and feeding (and other tabular histories in scope) support pagination or load-more (not silently truncated to first page)
  - Empty last pages and first-page empty states use FR-5 primitives
  - API is updated where list/history contracts cannot support the chosen page size / metadata needs
- **Priority**: Must
- **Related Stories**: TBD

### FR-7: Mobile detail and history visual parity

- **Description**: Align mobile detail and history presentations with the refreshed visual system (cards/sections consistent with `EntityListCard` and tokens), instead of raw dense `ListTile` / stacked field blocks that feel unfinished next to list cards.
- **Acceptance Criteria**:
  - Cow, poultry, crops, inventory, and ledger detail screens use shared section/card surfaces from the visual system
  - History subsections (e.g. milk, feeding, stock movements) use consistent row/card or table-like patterns within mobile constraints
  - Forms on detail and create flows share field labeling, spacing, and primary/secondary button placement
- **Priority**: Must
- **Related Stories**: TBD

### FR-8: Form and filter consistency (web + mobile)

- **Description**: Standardize forms and filters so date, numeric, and select inputs behave consistently across platforms and domains (e.g. date filters use proper date controls where the platform supports them; required labels are visible, not placeholder-only).
- **Acceptance Criteria**:
  - Web and mobile create/edit forms for primary entities show visible labels for all required fields
  - Date filters use native date pickers or equivalent typed date controls on both clients where the field is a date
  - Validation and error display next to fields follow one pattern per client
  - Weight and similar units keep clear unit labeling established in intent `002` (e.g. Weight (kg))
- **Priority**: Should
- **Related Stories**: TBD

### FR-9: Practical accessibility pass (web + mobile)

- **Description**: Close obvious accessibility gaps that block production readiness: semantic structure, focus visibility, and Flutter semantics on key interactive elements—aligned with `ux-guide.md` practical WCAG-minded v1 (not a full audit gate).
- **Acceptance Criteria**:
  - Web interactive controls in shell and primary flows show visible focus styles
  - Meaningful images (e.g. profile, cow image) have non-empty `alt` / accessible names when content-bearing; decorative images are marked appropriately
  - Mobile primary nav and list cards expose Semantics (or equivalent) labels for screen readers on key actions
  - No keyboard trap on web shell drawer/popovers (see FR-2)
- **Priority**: Must
- **Related Stories**: TBD

### FR-10: API updates only to support redesign

- **Description**: Change backend/API contracts solely when required by FR-1–FR-17 (pagination metadata, row **Total** fields or computed totals, update/delete for table row actions, image URLs already used by UI). No unrelated domain rewrites.
- **Acceptance Criteria**:
  - Every API change maps to a documented web or mobile design need in this intent
  - Update/delete endpoints (or documented equivalents) exist for tabular sub-records that expose Action Edit/Delete (at minimum cow milk and feeding; other domains as their tables gain Action)
  - Totals needed by UI are either returned by API or unambiguously computable from returned fields; Feeding and other priced/qty rows support a clear **Total**
  - Web and mobile clients stay in sync with any contract change
  - Breaking changes are versioned or coordinated; undocumented client-only assumptions are removed
  - No new business domains or staff/role APIs
- **Priority**: Must
- **Related Stories**: TBD

### FR-11: Developer design foundation documentation

- **Description**: Document the production-ready patterns (tokens, shell, page/list layout, empty/loading/error, pagination, table + Action column) so developers can complete key integration tasks—adding a list screen, a detail section, and a form—without reverse-engineering one-off pages.
- **Acceptance Criteria**:
  - Short developer-facing notes exist (in repo standards or intent artifacts) listing the shared components/patterns to reuse on web and mobile
  - A developer can identify the correct shared primitive for list, table, empty, loading, error, Action column, and shell usage from that documentation
- **Priority**: Should
- **Related Stories**: TBD

### FR-12: Row Total column on data tables (including Feeding)

- **Description**: Where a row has quantity and unit price/cost (or another clear monetary/quantity total), the UI shows a **Total**. **Cow Feeding** must include **Total** (and **unit cost**) with parity to Milk production. Apply on **web and mobile**. Apply the same rule to every other display-data table where a total is meaningful.
- **Acceptance Criteria**:
  - **Web**: Cow Feeding table includes **Unit cost** and **Total** per row; Milk retains **Total**
  - **Mobile**: Cow feeding and milk history rows show **Total** when meaningful; feeding shows **unit cost** (or equivalent labeled field) so Total is understandable
  - Other tabular views that have computable totals show **Total** when meaningful; tables without a natural total omit it
  - API updated if total cannot be derived reliably from existing fields (FR-10) — already delivered via bolt `024` (`unit_cost`, response `total`)
- **Priority**: Must
- **Related Stories**: `004-web-table-totals-and-actions`, `004-mobile-totals-actions-cow-layout`

### FR-13: Table Action column — Edit and Delete

- **Description**: After data is inserted, display-data tables/lists include **Edit** and **Delete** controls per row. Confirm before delete. Wire to API update/delete (FR-10). Required on **web and mobile** for cow milk and feeding at minimum; extend to other in-scope data tables.
- **Acceptance Criteria**:
  - **Web**: Column header **Action**; each row shows edit and delete icons; edit opens edit flow; delete confirms then removes and refreshes
  - **Mobile**: Cow milk and feeding history rows expose Edit and Delete (icons or Material icon buttons) with accessible labels; edit opens an edit flow; delete confirms then removes and refreshes the list
  - Actions respect archive/read-only rules on both clients (archived cow: actions disabled or hidden consistently)
  - Both clients use the same PATCH/DELETE milk and feeding API contracts from bolt `024`
- **Priority**: Must
- **Related Stories**: `004-web-table-totals-and-actions`, `004-mobile-totals-actions-cow-layout`

### FR-14: Cow detail layout — rectangular image left, info right

- **Description**: On cow detail on **web and mobile**, the cow image displays as a **rectangle on the left** (or top-leading on narrow phones) with cow information on the **right**/following region (not circular avatar-only as the sole layout).
- **Acceptance Criteria**:
  - When an image exists, layout is two-region: rectangular image + identity/details (responsive stack allowed only on narrow viewports)
  - Image uses a rectangular aspect (not circular avatar-only styling for the cow photo)
  - Missing image shows a rectangular placeholder in the same layout slot
  - Image has a meaningful accessible name when content-bearing
  - Behavior is required on web and on Flutter cow detail
- **Priority**: Must
- **Related Stories**: `005-web-cow-detail-chrome`, `004-mobile-totals-actions-cow-layout`

### FR-15: Remove in-page “← Back to …” links

- **Description**: After navigating into a detail/inner page, remove top **← Back to cows**, **← Back to poultry**, and equivalent back links from all pages. Rely on shell navigation (and browser/OS back where natural) instead.
- **Acceptance Criteria**:
  - No “← Back to …” (or equivalent) link appears at the top of detail/inner pages across cows, poultry, crops, inventory, income/expenses, profile, and settings
  - Users can still reach parent lists via the left menubar (web) or mobile shell navigation (FR-3)
- **Priority**: Must
- **Related Stories**: TBD

### FR-16: Refresh Edit and Archive buttons

- **Description**: Update the visual treatment and placement of **Edit** and **Archive** (and Cancel edit when active) on detail toolbars so they match the production-ready button system (clear primary/secondary hierarchy, consistent with FR-1 tokens)—not ad-hoc ghost-only pairs that feel unfinished.
- **Acceptance Criteria**:
  - Edit and Archive are visibly distinct and consistent across entity detail pages that support them
  - Button styles use shared button classes/tokens (not one-off inline styles)
  - Archive remains confirmatory (confirm dialog or equivalent) before archiving
  - When editing, Cancel/Save (or existing edit dismiss) remains clear next to Edit state
- **Priority**: Must
- **Related Stories**: TBD

---

## Non-Functional Requirements

### NFR-1: Usability (farm owner)

- **Metric**: Farm owner can complete core tasks—sign-in, open each primary domain list, open one detail, create one record per domain (cows, poultry, crops, inventory, income/expenses)—on web and on mobile without encountering a design blocker (broken nav, truncated-only lists with no way to see more, missing empty/error feedback, unusable mobile nav overflow)
- **Target**: 100% of listed core tasks completable on both clients after this intent
- **Notes**: Exact click/tap budgets may be refined in construction; FR-3 requires ≤ 2 taps to destinations from mobile shell

### NFR-2: Consistency

- **Metric**: Shared tokens drive shell and primary entity screens; list/empty/loading/error patterns match within each client; cross-client brand color and typography roles align
- **Target**: No primary signed-in domain screen outside the shared patterns without a documented exception

### NFR-3: Developer effectiveness

- **Metric**: Developer can add a new entity list screen using shared layout + state primitives without copying an entire existing page file as a starting point
- **Target**: Demonstrated once in construction notes or a thin example/refactor of an existing list

### NFR-4: Compatibility / no domain regression

- **Metric**: Intent `001` workflows remain completable; intent `002` cow image, auto-tag, and web milk/feeding pagination behaviors remain intact unless explicitly replaced by a better production pattern documented here
- **Target**: No blocking regressions on auth and five domain happy paths

### NFR-5: Performance (perceived list UX)

- **Metric**: Changing list/history page (or load-more) returns usable UI feedback within 2s on local/dev API under normal dataset sizes; loading primitive visible until data or error
- **Target**: Met for paginated lists in FR-6

### NFR-6: Localization

- **Metric**: Mobile keeps BN/EN for new/changed user-visible strings; web may remain English-only this intent but must not introduce hard-to-extract inline copy sprawl beyond existing practice
- **Target**: No new mobile user-facing string hard-coded outside l10n

---

## Constraints

### Technical Constraints

**Project-wide standards**: Required standards will be loaded from memory-bank standards folder by Construction Agent (`ux-guide`, `tech-stack`, `coding-standards`, `api-conventions`).

**Intent-specific constraints**:

- Prefer extending intent `002` shell/tokens/components over greenfield redesign of working pieces
- API changes must be justified by a concrete web or mobile design need (FR-10)
- No formal full WCAG audit gate; fix practical barriers (FR-9)

### Business Constraints

- Stakeholders: developers and farm owners
- Scope limited to design production-readiness; not a new product domain
- No specific regulatory or hard timeline constraints identified at inception

---

## Assumptions

| Assumption                                                                                                                          | Risk if Invalid                    | Mitigation                                             |
| ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------ |
| Intent `001` domain workflows remain the baseline feature set                                                                       | Redesign expands into new features | Enforce out-of-scope; review at Checkpoint 2/3         |
| Intent `002` shell/tokens are reusable baseline, not finished production bar                                                        | Underestimating rework             | FR-1–FR-3 explicitly polish gaps                       |
| Existing list/history APIs already expose offset/limit sufficient for FR-6                                                          | Pagination UI blocked              | FR-10 allows minimal API metadata fixes                |
| “Production ready” means usable, consistent, accessible-enough for v1 farm owners + developers—not marketing polish or store launch | Scope disagreement                 | Checkpoint 2 approval locks the bar via FR/NFR metrics |

---

## Open Questions

| Question                                                                            | Owner         | Due Date                    | Resolution                                                                                      |
| ----------------------------------------------------------------------------------- | ------------- | --------------------------- | ----------------------------------------------------------------------------------------------- |
| Default page size for primary entity lists (10 vs 20)?                              | Product owner | Checkpoint 2                | **Resolved: 10** (parity with Milk production)                                                  |
| Mobile nav pattern preference (drawer vs bottom navigation vs other)?               | Product owner | Checkpoint 2 / construction | **Resolved: navigation drawer** + TitleBar ⋮ (Profile, Logout with confirm dialog)              |
| Feeding Total formula (e.g. quantity × unit cost) when API fields differ from milk? | Developer     | During construction         | Pending — align with stored feeding fields; extend API if unit cost missing                     |
| Soft-delete vs hard-delete for table row Delete?                                    | Product owner | Checkpoint 2 / construction | Pending — default hard-delete for sub-records (milk/feeding) unless owner specifies soft-delete |
