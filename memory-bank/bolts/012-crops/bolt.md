---
id: 012-crops
unit: 004-crops
intent: 001-farm-management-first-release
type: simple-construction-bolt
status: planned
stories:
  - 004-mobile-crops
created: 2026-11-09T06:55:29Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ['011-crops']
enables_bolts: ['013-inventory']
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 012-crops

## Overview

Mobile UI for Crops for intent `001-farm-management-first-release`.

## Objective

Mobile UI for Crops while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [ ] **004-mobile-crops**: Mobile crops workflows - Priority: Must

## Bolt Type

**Type**: simple-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Spec/Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → code
- [ ] **3. Test**: Pending → test-report.md

## Dependencies

### Requires
- 011-crops

### Enables
- 013-inventory

## Success Criteria

- [ ] All included stories implemented
- [ ] All acceptance criteria met
- [ ] Tests for critical paths passing
- [ ] No feature scope beyond this slice

## Notes

Do not start Construction until Checkpoint 3/4 approvals. Hosting remains TBD.
