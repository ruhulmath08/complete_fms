---
id: 020-design-web
unit: 002-design-web
intent: 002-design-system-refresh
type: simple-construction-bolt
status: planned
stories:
  - 001-web-app-shell
  - 002-web-design-tokens
created: 2026-11-11T18:01:56Z
started: null
completed: null
current_stage: null
stages_completed: []

requires_bolts: []
enables_bolts: ["021-design-web"]
requires_units: []
blocks: false

complexity:
  avg_complexity: 2
  avg_uncertainty: 1
  max_dependencies: 1
  testing_scope: 2
---

# Bolt: 020-design-web

## Overview

Web app shell and shared design tokens for the visual refresh.

## Objective

Ship left sidebar (`#2f6a3a` / white text), show/hide, header/footer, notification + profile chrome, and shared tokens/components.

## Stories Included

- [ ] **001-web-app-shell**: Web app shell - Priority: Must
- [ ] **002-web-design-tokens**: Web design tokens - Priority: Should

## Bolt Type

**Type**: simple-construction-bolt  
**Definition**: `.specsmd/aidlc/templates/construction/bolt-types/simple-construction-bolt.md`

## Stages

- [ ] **1. Plan**: Pending → implementation-plan.md
- [ ] **2. Implement**: Pending → implementation-walkthrough.md
- [ ] **3. Test**: Pending → test-walkthrough.md

## Dependencies

### Requires

- None (can run in parallel with 019-design-api)

### Enables

- 021-design-web

## Success Criteria

- [ ] Shell on signed-in pages with brand menubar
- [ ] Tokens/components reused by shell
- [ ] Basic navigation smoke tests pass
