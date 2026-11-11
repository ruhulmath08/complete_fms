---
id: 023-design-mobile
unit: 003-design-mobile
intent: 002-design-system-refresh
type: simple-construction-bolt
status: planned
stories:
  - 003-mobile-cow-create-refresh
  - 004-mobile-consume-auto-tag-and-image
created: 2026-11-11T18:01:56Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: ["019-design-api", "022-design-mobile"]
enables_bolts: []
requires_units: ["001-design-api"]
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 2
  max_dependencies: 3
  testing_scope: 2
---

# Bolt: 023-design-mobile

## Overview

Mobile cow create/detail refresh for image, Weight (kg), and API-generated tags.

## Objective

Align Flutter cow flows with the new API contracts and refreshed visual tokens/cards.

## Stories Included

- [ ] **003-mobile-cow-create-refresh**: Mobile cow create refresh - Priority: Must
- [ ] **004-mobile-consume-auto-tag-and-image**: Mobile consume auto tag and image - Priority: Must

## Bolt Type

**Type**: simple-construction-bolt  
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → implementation-walkthrough.md
- [ ] **3. Test**: Pending → test-walkthrough.md

## Dependencies

### Requires

- 019-design-api (Required): tag + image APIs
- 022-design-mobile (Required): cards + tokens baseline

### Enables

- None

## Success Criteria

- [ ] Cow create shows image + Weight (kg)
- [ ] Tag comes from API; image displays on detail
- [ ] Tests/smoke for create + display paths
