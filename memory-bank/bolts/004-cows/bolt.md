---
id: 004-cows
unit: 002-cows
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-cow-records
  - 002-api-cow-milk-and-feeding
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['003-platform-and-auth']
enables_bolts: ['005-cows']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 004-cows

## Overview

API for Cows for intent `001-farm-management-first-release`.

## Objective

API for Cows while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **001-api-cow-records**: API cow records - Priority: Must
- [ ] **002-api-cow-milk-and-feeding**: API cow milk and feeding - Priority: Must

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
- 003-platform-and-auth

### Enables
- 005-cows

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
