---
id: 007-poultry
unit: 003-poultry
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-poultry-groups
  - 002-api-poultry-feeding-and-eggs
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['006-cows']
enables_bolts: ['008-poultry']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 007-poultry

## Overview

API for Poultry for intent `001-farm-management-first-release`.

## Objective

API for Poultry while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **001-api-poultry-groups**: API poultry groups - Priority: Must
- [ ] **002-api-poultry-feeding-and-eggs**: API poultry feeding and eggs - Priority: Must

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
- 006-cows

### Enables
- 008-poultry

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
