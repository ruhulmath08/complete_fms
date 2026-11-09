---
id: 016-income-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-income-and-expenses
created: 2026-11-09T06:55:29Z
started: 2026-11-09T13:13:23Z
completed: 2026-11-09T13:21:48Z
current_stage: null
stages_completed:
  - name: model
    completed: 2026-11-09T13:13:23Z
    artifact: ddd-01-domain-model.md
  - name: design
    completed: 2026-11-09T13:15:17Z
    artifact: ddd-02-technical-design.md
  - name: adr
    completed: 2026-11-09T13:16:58Z
    artifact: null
    notes: No ADR-worthy decisions; reuse ADR-004
  - name: implement
    completed: 2026-11-09T13:20:36Z
    artifact: implementation-walkthrough.md
  - name: test
    completed: 2026-11-09T13:21:48Z
    artifact: ddd-03-test-report.md

requires_bolts: ["015-inventory"]
enables_bolts: ["017-income-expenses"]
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 016-income-expenses

## Overview

API for Income and Expenses for intent `001-farm-management-first-release`.

## Objective

API for Income and Expenses while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [x] **001-api-income-and-expenses**: API income and expenses - Priority: Must

## Bolt Type

**Type**: ddd-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/ddd-construction-bolt.md`

## Stages

- [x] **1. Domain Model**: Complete → ddd-01-domain-model.md
- [x] **2. Technical Design**: Complete → ddd-02-technical-design.md
- [x] **3. ADR Analysis**: Skipped — no new ADR; reuse ADR-004
- [x] **4. Implement**: Complete → implementation-walkthrough.md
- [x] **5. Test**: Complete → ddd-03-test-report.md

## Dependencies

### Requires

- 015-inventory (complete)

### Enables

- 017-income-expenses

## Success Criteria

- [x] All included stories implemented
- [x] All acceptance criteria met
- [x] Tests for critical paths passing
- [x] No feature scope beyond this slice

## Notes

Construction started 2026-11-09T13:13:23Z. Completed 2026-11-09T13:21:48Z.
