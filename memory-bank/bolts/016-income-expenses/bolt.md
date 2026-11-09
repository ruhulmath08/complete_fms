---
id: 016-income-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-income-and-expenses
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['015-inventory']
enables_bolts: ['017-income-expenses']
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

- [ ] **001-api-income-and-expenses**: API income and expenses - Priority: Must

## Bolt Type

**Type**: ddd-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/ddd-construction-bolt.md`

## Stages

- [ ] **1. Domain Model**: Pending → ddd-01-domain-model.md
- [ ] **2. Technical Design**: Pending → ddd-02-technical-design.md
- [ ] **3. ADR Analysis**: Optional
- [ ] **4. Implement**: Pending → code
- [ ] **5. Test**: Pending → ddd-03-test-report.md

## Dependencies

### Requires
- 015-inventory

### Enables
- 017-income-expenses

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
