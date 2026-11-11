---
id: 022-design-mobile
unit: 003-design-mobile
intent: 002-design-system-refresh
type: simple-construction-bolt
status: complete
stories:
  - 001-mobile-list-cards
  - 002-mobile-design-tokens
created: '2026-11-11T18:01:56Z'
started: '2026-11-11T18:32:30Z'
completed: '2026-11-11T18:39:03Z'
current_stage: null
stages_completed:
  - name: plan
    completed: '2026-11-11T18:35:35Z'
    artifact: implementation-plan.md
  - name: implement
    completed: '2026-11-11T18:38:00Z'
    artifact: implementation-walkthrough.md
requires_bolts: []
enables_bolts:
  - 023-design-mobile
requires_units: []
blocks: false
complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 1
  testing_scope: 2
---

# Bolt: 022-design-mobile

## Overview

Mobile card list layouts and mirrored design tokens.

## Objective

Refresh primary Flutter list screens to cards and centralize brand tokens (`#2f6a3a` where used).

## Stories Included

- [ ] **001-mobile-list-cards**: Mobile list cards - Priority: Must
- [ ] **002-mobile-design-tokens**: Mobile design tokens - Priority: Should

## Bolt Type

**Type**: simple-construction-bolt  
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → implementation-walkthrough.md
- [ ] **3. Test**: Pending → test-walkthrough.md

## Dependencies

### Requires

- None (can run in parallel with 019/020)

### Enables

- 023-design-mobile

## Success Criteria

- [ ] Domain lists use cards
- [ ] Tokens defined centrally and applied to cards/theme
