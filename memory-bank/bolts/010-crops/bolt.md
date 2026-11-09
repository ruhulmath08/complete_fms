---
id: 010-crops
unit: 004-crops
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: planned
stories:
  - 001-api-crop-names-and-cycles
  - 002-api-crop-expenses-harvests-summary
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['009-poultry']
enables_bolts: ['011-crops']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 010-crops

## Overview

API for Crops for intent `001-farm-management-first-release`.

## Objective

API for Crops while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **001-api-crop-names-and-cycles**: API crop names and cycles - Priority: Must
- [ ] **002-api-crop-expenses-harvests-summary**: API crop expenses harvests summary - Priority: Must

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
- 009-poultry

### Enables
- 011-crops

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
