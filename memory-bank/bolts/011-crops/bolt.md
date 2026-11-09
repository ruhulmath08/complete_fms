---
id: 011-crops
unit: 004-crops
intent: 001-farm-management-first-release
type: simple-construction-bolt
status: complete
stories:
  - 003-web-crops
created: 2026-11-09T06:55:29Z
started: 2026-11-09T12:14:33Z
completed: 2026-11-09T12:28:00Z
current_stage: null
stages_completed:
  - name: plan
    completed: 2026-11-09T12:20:00Z
    artifact: implementation-plan.md
  - name: implement
    completed: 2026-11-09T12:20:00Z
    artifact: implementation-walkthrough.md
  - name: test
    completed: 2026-11-09T12:28:00Z
    artifact: test-walkthrough.md

requires_bolts: ["010-crops"]
enables_bolts: ["012-crops"]
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 011-crops

## Overview

Web UI for Crops for intent `001-farm-management-first-release`.

## Objective

Web UI for Crops while keeping API contracts consistent across backend, React, and Flutter.

## Stories Included

- [x] **003-web-crops**: Web crops workflows - Priority: Must

## Bolt Type

**Type**: simple-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [x] **1. Plan**: Complete → implementation-plan.md
- [x] **2. Implement**: Complete → implementation-walkthrough.md
- [x] **3. Test**: Complete → test-walkthrough.md

## Dependencies

### Requires

- 010-crops (complete)

### Enables

- 012-crops

## Success Criteria

- [x] All included stories implemented
- [x] All acceptance criteria met
- [x] Tests for critical paths passing
- [x] No feature scope beyond this slice

## Notes

Construction started 2026-11-09T12:14:33Z. Completed 2026-11-09T12:28:00Z.
