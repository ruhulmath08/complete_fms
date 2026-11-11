---
id: 021-design-web
unit: 002-design-web
intent: 002-design-system-refresh
type: simple-construction-bolt
status: complete
stories:
  - 003-web-add-cow-image-and-labels
  - 004-web-milk-feeding-tables
  - 005-web-tabular-lists
created: '2026-11-11T18:01:56Z'
started: '2026-11-11T18:27:24Z'
completed: '2026-11-11T18:31:46Z'
current_stage: null
stages_completed:
  - name: plan
    completed: '2026-11-11T18:30:21Z'
    artifact: implementation-plan.md
  - name: implement
    completed: '2026-11-11T18:30:51Z'
    artifact: implementation-walkthrough.md
requires_bolts:
  - 019-design-api
  - 020-design-web
enables_bolts: []
requires_units:
  - 001-design-api
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 3
  testing_scope: 2
---

# Bolt: 021-design-web

## Overview

Web cow form refresh, milk/feeding Bootstrap tables with pagination, and broader tabular lists.

## Objective

Wire add-cow image/labels/auto-tag and paginated history tables on top of the new shell and API contracts.

## Stories Included

- [ ] **003-web-add-cow-image-and-labels**: Web add cow image and labels - Priority: Must
- [ ] **004-web-milk-feeding-tables**: Web milk and feeding tables - Priority: Must
- [ ] **005-web-tabular-lists**: Web tabular lists - Priority: Should

## Bolt Type

**Type**: simple-construction-bolt  
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → implementation-walkthrough.md
- [ ] **3. Test**: Pending → test-walkthrough.md

## Dependencies

### Requires

- 019-design-api (Required): tag, image, pagination APIs
- 020-design-web (Required): shell + tokens

### Enables

- None

## Success Criteria

- [ ] Add-cow image + Weight (kg) + generated tag
- [ ] Milk/feeding tables page size 10
- [ ] Tabular list preference applied where practical
