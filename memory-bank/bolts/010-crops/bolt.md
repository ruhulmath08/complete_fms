---
id: 010-crops
unit: 004-crops
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-crop-names-and-cycles
  - 002-api-crop-expenses-harvests-summary
created: 2026-11-09T06:55:29Z
started: 2026-11-09T11:59:40Z
completed: 2026-11-09T12:14:33Z
current_stage: null
stages_completed:
  - name: model
    completed: 2026-11-09T12:02:06Z
    artifact: ddd-01-domain-model.md
  - name: design
    completed: 2026-11-09T12:03:54Z
    artifact: ddd-02-technical-design.md
  - name: adr-analysis
    completed: 2026-11-09T12:07:28Z
    artifacts:
      - adr-007-active-crop-name-uniqueness.md
  - name: implement
    completed: 2026-11-09T12:12:00Z
    artifact: implementation-walkthrough.md
  - name: test
    completed: 2026-11-09T12:14:33Z
    artifact: ddd-03-test-report.md

requires_bolts: ["009-poultry"]
enables_bolts: ["011-crops"]
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

- [x] **001-api-crop-names-and-cycles**: API crop names and cycles - Priority: Must
- [x] **002-api-crop-expenses-harvests-summary**: API crop expenses harvests summary - Priority: Must

## Bolt Type

**Type**: ddd-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/ddd-construction-bolt.md`

## Stages

- [x] **1. Domain Model**: Complete → ddd-01-domain-model.md
- [x] **2. Technical Design**: Complete → ddd-02-technical-design.md
- [x] **3. ADR Analysis**: Complete → ADR-007
- [x] **4. Implement**: Complete → implementation-walkthrough.md
- [x] **5. Test**: Complete → ddd-03-test-report.md

## Dependencies

### Requires

- 009-poultry (complete)

### Enables

- 011-crops

## Success Criteria

- [x] All included stories implemented
- [x] All acceptance criteria met
- [x] Tests for critical paths passing
- [x] No feature scope beyond this slice

## Notes

Construction started 2026-11-09T11:59:40Z. Completed 2026-11-09T12:14:33Z.
