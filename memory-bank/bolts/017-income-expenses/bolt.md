---
id: 017-income-expenses
unit: 006-income-expenses
intent: 001-farm-management-first-release
type: simple-construction-bolt
status: planned
stories:
  - 002-web-income-and-expenses
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['016-income-expenses']
enables_bolts: ['018-income-expenses']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 017-income-expenses

## Overview

Web UI for Income and Expenses for intent `001-farm-management-first-release`.

## Objective

Web UI for Income and Expenses while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **002-web-income-and-expenses**: Web income and expenses - Priority: Must

## Bolt Type

**Type**: simple-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Spec/Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → code
- [ ] **3. Test**: Pending → test-report.md

## Dependencies

### Requires
- 016-income-expenses

### Enables
- 018-income-expenses

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
