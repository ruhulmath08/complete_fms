---
intent: 004-poultry-history-actions-and-table-polish
phase: inception
status: units-defined
created: '2026-11-12T09:35:38Z'
updated: '2026-11-12T09:49:18Z'
type: enhancement
---

# Requirements: Poultry History Actions and Table Polish

## Intent Overview

Extend production history-table UX so farm owners can **add/edit/delete** poultry **Egg production** and **Feeding** rows on **web and mobile** without design or API blockers. Deliver poultry-row **PATCH/DELETE** APIs, per-row **Action** (Edit primary / Delete danger), and rename the row-index column from **`#`** to **`No.`** on **all** history tables across FastAPI clients (React + Flutter). Builds on sealed intent `003` (FR-13 extension) without reopening that program.

## Business Goals

| Goal                                 | Success Metric                                                                                                              | Priority |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- | -------- |
| Maintain poultry egg/feeding history | Farm owner can add, edit, and delete at least one egg and one feeding row on web and on mobile without a design/API blocker | Must     |
| Consistent Action affordances        | Edit uses primary styling; Delete uses red/danger; delete confirms before remove                                            | Must     |
| Consistent row index label           | All history tables use column title **No.** (not `#`) on web and equivalent label on mobile                                 | Must     |
| Developer clarity                    | API + UI patterns match cow milk/feeding Action from intent `003` / bolt `024`                                              | Should   |

## Beneficiaries

- **Farm owners** — edit/delete poultry history after insert
- **Developers** — reuse 003 Action/table patterns with poultry contracts

---

## Scope

### In Scope

- FastAPI: PATCH + DELETE for poultry **egg productions** and **poultry feedings** (owner-scoped; archived-group rules parity with cow milk/feeding)
- React: Action column on poultry Egg production & Feeding tables; Edit primary / Delete danger; confirm delete; wire to new APIs
- Flutter: Edit/Delete (with confirm) on poultry egg & feeding histories; wire to same APIs; BN/EN strings
- **All history tables** (web + mobile): rename row-index header/label `#` → **`No.`** (poultry egg/feeding, cow milk/feeding, crop expenses/harvests, and any other in-app history tables using `#`)
- Align existing cow milk/feeding Action icon colors to Edit = primary, Delete = danger if not already
- Tests for API + critical-path web/mobile coverage
- Short note in web UI patterns / mobile docs if Action color + `No.` convention is documented

### Out of Scope

- Reopening intent `003` wholesale redesign
- Soft-delete (hard-delete only)
- New farm domains
- Changing poultry group CRUD beyond history Action
- Full WCAG audit

---

## Functional Requirements

### FR-1: Poultry egg production update and delete (API)

- **Description**: Provide owner-scoped PATCH and DELETE for egg production rows so web/mobile Action columns can maintain data after insert.
- **Acceptance Criteria**:
  - `PATCH /api/v1/poultry-groups/{group_id}/egg-productions/{egg_id}` updates allowed fields and returns the updated resource
  - `DELETE .../egg-productions/{egg_id}` hard-deletes the row and returns `204`
  - Missing/cross-owner/wrong-group rows return not-found style errors consistent with cows module
  - Archived poultry group blocks update/delete (parity with archived cow rules)
  - Unauthenticated requests denied
- **Priority**: Must
- **Related Stories**: TBD

### FR-2: Poultry feeding update and delete (API)

- **Description**: Provide owner-scoped PATCH and DELETE for poultry feeding rows, same pattern as FR-1 / cow feedings.
- **Acceptance Criteria**:
  - `PATCH /api/v1/poultry-groups/{group_id}/feedings/{feeding_id}` updates allowed fields and returns the updated resource
  - `DELETE .../feedings/{feeding_id}` hard-deletes and returns `204`
  - Same ownership, archive, and authz rules as FR-1
- **Priority**: Must
- **Related Stories**: TBD

### FR-3: Web poultry Egg production — Action column

- **Description**: On poultry detail Egg production table, add **Action** with Edit (primary) and Delete (danger/red); confirm before delete; refresh list after success.
- **Acceptance Criteria**:
  - Column header **Action** present when rows exist (and when actions are available)
  - Edit control uses primary color styling; opens inline/edit flow; saves via PATCH; table refreshes
  - Delete control uses red/danger styling; confirmation dialog; DELETE then refresh
  - Actions hidden or disabled when group is archived / eggs not eligible
  - Accessible names on icon buttons (e.g. Edit egg entry, Delete egg entry)
- **Priority**: Must
- **Related Stories**: TBD

### FR-4: Web poultry Feeding — Action column

- **Description**: Same Action behavior as FR-3 for the poultry Feeding table.
- **Acceptance Criteria**:
  - Action Edit (primary) / Delete (danger) with confirm; wired to FR-2 APIs
  - Archived group: actions hidden or disabled consistently with FR-3
- **Priority**: Must
- **Related Stories**: TBD

### FR-5: Mobile poultry egg and feeding — Edit/Delete

- **Description**: Flutter poultry detail histories expose Edit and Delete for egg and feeding rows with confirm on delete, using the same API contracts as web.
- **Acceptance Criteria**:
  - Farm owner can edit and delete at least one egg and one feeding entry on mobile
  - Delete shows an alert dialog (title, message, Confirm, Cancel)
  - Edit opens an edit flow (dialog/sheet/form) and persists via PATCH
  - Archived / non-eligible groups: mutations disabled or hidden
  - BN/EN l10n for new strings
- **Priority**: Must
- **Related Stories**: TBD

### FR-6: Row index column titled **No.** (all history tables)

- **Description**: Replace the row-index column title **`#`** with **`No.`** on every history/sub-record table in the React and Flutter apps (and keep API clients consistent with that UX convention). Applies to poultry egg/feeding, cow milk/feeding, crop expenses/harvests, and any other history tables currently labeled `#`.
- **Acceptance Criteria**:
  - Web: no history table header shows `#` as the index column; all use **No.** (or localized equivalent if l10n is introduced for that header)
  - Mobile: row number label uses **No.** / existing `rowNumber` (or BN equivalent) consistently on history UIs that show an index
  - Cow milk/feeding index headers updated if they still use `#`
- **Priority**: Must
- **Related Stories**: TBD

### FR-7: Action control colors — Edit primary, Delete danger

- **Description**: Across history Action affordances (at minimum poultry egg/feeding and cow milk/feeding on web; mobile icon colors aligned to theme primary/danger), Edit is primary-colored and Delete is red/danger-colored.
- **Acceptance Criteria**:
  - Web `.btn-icon` / Action edit uses primary color treatment; delete uses danger/red treatment (distinct from neutral ghost)
  - Mobile Edit/Delete icons or buttons use primary vs danger theme colors
  - Contrast remains readable on light surfaces
- **Priority**: Must
- **Related Stories**: TBD

### FR-8: Add path remains usable (egg + feeding)

- **Description**: Existing add/create flows for egg and feeding continue to work on web and mobile alongside Edit/Delete (success metric includes add).
- **Acceptance Criteria**:
  - Farm owner can still add a new egg entry and a new feeding entry on web and mobile after this intent
  - No regression to create/list pagination behavior from intent `003`
- **Priority**: Must
- **Related Stories**: TBD

---

## Non-Functional Requirements

### NFR-1: Contract parity with cow milk/feeding mutations

- **Metric**: Poultry egg/feeding PATCH/DELETE error codes and archive behavior mirror cows module conventions (not invent a second authz style)
- **Priority**: Must

### NFR-2: Test coverage (critical path)

- **Metric**: Backend tests cover poultry egg/feeding update/delete + archive/authz; web and mobile critical-path tests or documented smoke for Action flows
- **Priority**: Must

### NFR-3: Localization (mobile)

- **Metric**: New user-visible strings for Action/confirm/`No.` appear in EN and BN ARBs
- **Priority**: Must

### NFR-4: No unrelated API churn

- **Metric**: Only poultry egg/feeding mutation contracts (plus docs) change unless required for FR-6/FR-7 client polish
- **Priority**: Should

---

## Technical Constraints

- Hard-delete only (no soft-delete)
- Reuse intent `003` web/mobile Action and pagination patterns
- Stack: FastAPI + React (Vite) + Flutter; existing JWT owner auth
- Project standards in `memory-bank/standards/` apply (do not duplicate)

## Dependencies

| Dependency               | Why                                                     |
| ------------------------ | ------------------------------------------------------- |
| Intent `003` complete    | Table/Action/Total patterns; cow milk/feeding reference |
| Poultry create/list APIs | Existing egg/feeding POST + list                        |

## Open Questions

| Question            | Resolution                                            |
| ------------------- | ----------------------------------------------------- |
| Soft vs hard delete | **Hard-delete** (product owner Checkpoint 1)          |
| `#` → `No.` scope   | **All history tables** on web + mobile (Checkpoint 1) |
| Beneficiaries       | Farm owners + developers (Checkpoint 1)               |

## Success Criteria (intent-level)

- [ ] Farm owner can **add**, **edit**, and **delete** one egg and one feeding row on **web** without a design/API blocker
- [ ] Same on **mobile**
- [ ] History tables use **No.** not `#`
- [ ] Edit primary / Delete red on Action controls
