---
id: 019-design-api
unit: 001-design-api
intent: 002-design-system-refresh
type: ddd-construction-bolt
status: complete
stories:
  - 001-api-auto-tag-number
  - 002-api-cow-image
  - 003-api-milk-feeding-pagination
created: '2026-11-11T18:01:56Z'
started: '2026-11-11T18:11:36Z'
completed: '2026-11-11T18:20:20Z'
current_stage: null
stages_completed:
  - name: domain-model
    completed: '2026-11-11T18:12:47Z'
    artifact: ddd-01-domain-model.md
  - name: technical-design
    completed: '2026-11-11T18:14:48Z'
    artifact: ddd-02-technical-design.md
  - name: adr-analysis
    completed: '2026-11-11T18:14:48Z'
    artifact: null
  - name: implement
    completed: '2026-11-11T18:19:36Z'
    artifact: implementation-walkthrough.md
  - name: test
    completed: '2026-11-11T18:20:20Z'
    artifact: ddd-03-test-report.md
requires_bolts: []
enables_bolts:
  - 021-design-web
  - 023-design-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 2
  testing_scope: 2
---

# Bolt: 019-design-api

## Overview

API contract and domain updates for design-system refresh: auto tag numbers, cow images, and milk/feeding pagination.

## Objective

Deliver backend behaviors and OpenAPI updates that web and mobile design bolts depend on.

## Stories Included

- [ ] **001-api-auto-tag-number**: API auto tag number - Priority: Must
- [ ] **002-api-cow-image**: API cow image - Priority: Must
- [ ] **003-api-milk-feeding-pagination**: API milk/feeding pagination - Priority: Must

## Bolt Type

**Type**: ddd-construction-bolt  
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/ddd-construction-bolt.md`

## Stages

- [ ] **1. Domain model**: Pending → ddd-01-domain-model.md
- [ ] **2. Technical design**: Pending → ddd-02-technical-design.md
- [ ] **3. Implement**: Pending → implementation-walkthrough.md
- [ ] **4. Test report**: Pending → ddd-03-test-report.md

## Dependencies

### Requires

- None (within this intent; extends intent 001 cows/platform)

### Enables

- 021-design-web
- 023-design-mobile

## Success Criteria

- [ ] All included stories implemented
- [ ] Acceptance criteria met
- [ ] Contract documented for clients
- [ ] Tests for tag uniqueness, image auth, and pagination
