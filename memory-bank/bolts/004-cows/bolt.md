---
id: 004-cows
unit: 002-cows
intent: 001-farm-management-first-release
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-cow-records
  - 002-api-cow-milk-and-feeding
created: '2026-11-09T06:55:29Z'
started: '2026-11-09T10:07:35Z'
completed: '2026-11-09T11:02:58Z'
current_stage: null
stages_completed:
  - name: model
    completed: '2026-11-09T10:15:40Z'
    artifact: ddd-01-domain-model.md
  - name: design
    completed: '2026-11-09T10:17:06Z'
    artifact: ddd-02-technical-design.md
  - name: adr-analysis
    completed: '2026-11-09T10:36:09Z'
    artifacts:
      - adr-004-soft-archive-livestock.md
      - adr-005-denormalized-owner-id-on-child-tables.md
      - adr-006-active-cow-tag-uniqueness.md
  - name: implement
    completed: '2026-11-09T11:00:59Z'
    artifact: backend/app/modules/cows/
  - name: test
    completed: '2026-11-09T11:02:45Z'
    artifact: ddd-03-test-report.md
requires_bolts:
  - 003-platform-and-auth
enables_bolts:
  - 005-cows
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

- [x] **001-api-cow-records**: API cow records - Priority: Must
- [x] **002-api-cow-milk-and-feeding**: API cow milk and feeding - Priority: Must

## Bolt Type

**Type**: ddd-construction-bolt
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/ddd-construction-bolt.md`

## Stages

- [x] **1. Domain Model**: Complete → ddd-01-domain-model.md
- [x] **2. Technical Design**: Complete → ddd-02-technical-design.md
- [x] **3. ADR Analysis**: Complete → adr-004, adr-005, adr-006
- [x] **4. Implement**: Complete → backend/app/modules/cows/
- [x] **5. Test**: Complete → ddd-03-test-report.md

## Dependencies

### Requires
- 003-platform-and-auth (complete)

### Enables
- 005-cows

## Success Criteria

- [x] All included stories implemented
- [x] All acceptance criteria met
- [x] Tests for critical paths passing
- [x] No feature scope beyond this slice

## Notes

Construction started 2026-11-09T10:07:35Z. Completed 2026-11-09T11:02:45Z.
