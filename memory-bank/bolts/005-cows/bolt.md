---
id: 005-cows
unit: 002-cows
intent: 001-farm-management-first-release
type: simple-construction-bolt
status: planned
stories:
  - 003-web-cows
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['004-cows']
enables_bolts: ['006-cows']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 005-cows

## Overview

Web UI for Cows for intent `001-farm-management-first-release`.

## Objective

Web UI for Cows while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **003-web-cows**: Web cows workflows - Priority: Must

## Bolt Type

**Type**: simple-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Spec/Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → code
- [ ] **3. Test**: Pending → test-report.md

## Dependencies

### Requires
- 004-cows

### Enables
- 006-cows

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
