---
name: repair-mode
description: Controlled implementation and verification workflow following a completed scientific diagnosis.
---

# Repair Mode

## Purpose

Repair Mode performs controlled modifications after a diagnostic has identified concrete problems.

Repair Mode MUST NOT begin merely because a problem is discovered.

It requires explicit user authorization or an unambiguous request to repair/fix the diagnosed target.

## Activation

Activate this workflow when the user asks to:

- start repair mode;
- fix the diagnosed phase;
- implement the proposed repairs;
- repair a specific module after diagnosis.

Examples:

"Start repair mode for Phase 2A."

"Proceed with the Phase-2A repairs."

"Fix the issues identified in the diagnostic."

## Preconditions

Before modifying files:

1. identify the target phase;
2. locate the most recent diagnostic findings;
3. confirm the proposed changes;
4. restrict changes to the affected modules unless dependency changes are necessary.

If no diagnosis exists, perform a diagnostic first rather than immediately making broad changes.

## Repair Procedure

### 1. Preserve scientific boundaries

Never:

- weaken mathematical or physical oracles;
- alter tests merely to make implementation pass;
- introduce dense symbolic d4 matrices;
- introduce dense symbolic diagonalization;
- expand unconstrained Schrieffer-Wolff fermionic products;
- replace exact symbolic identities with numerical approximations;
- silently change physical conventions.

### 2. Delegate implementation

When specialist agents are available:

- physics-implementer:
  modify implementation;

- test-generator:
  add or correct mathematical tests;

- execution-worker:
  execute the relevant test suite;

- physics-auditor:
  independently audit the resulting physics;

- complexity-auditor:
  independently check symbolic complexity.

Avoid having one agent both implement and independently validate its own physics.

### 3. Minimal changes

Prefer:

- smallest correct implementation change;
- preservation of public interfaces;
- localized modifications;
- explicit mathematical names;
- type-stable symbolic representations.

Do not refactor unrelated modules during a phase repair.

### 4. Test hierarchy

After modifications run, in order:

1. targeted tests;
2. phase-level tests;
3. complete repository tests when practical.

A passing test suite is necessary but not sufficient.

### 5. Mathematical verification

Verify the phase-specific physical oracles.

Phase 1:
- CAR;
- nilpotency/anticommutation;
- projector completeness;
- projector orthogonality;
- projector idempotency.

Phase 2A:
- jeff=1/2 construction;
- jeff=3/2 construction;
- exact energy gap 3λ/2.

Phase 2B:
- P_[L=0], P_[L=1], P_[L=2];
- exact Kanamori energies:
  ΔE0 = U + 2 J_H
  ΔE1 = U − 3 J_H
  ΔE2 = U − J_H.

Phase 3:
- J_H = 0 Jackeli-Khaliullin cancellation;
- λ_SOC → 0 gives K → 0;
- z-bond C2 symmetry:
  J_xx = J_yy.

Phase 4:
- Lean consistency;
- formal invariants;
- bond-distortion limits;
- local-potential limits.

### 6. Complexity verification

Check that the repair does not introduce:

- dense symbolic matrix diagonalization;
- uncontrolled expansion;
- symbolic expression blow-up;
- unnecessary repeated simplification;
- computationally expensive intermediate representations.

### 7. Final audit

After implementation:

1. run tests;
2. run physics audit;
3. run complexity audit;
4. inspect Git diff;
5. check that only intended files changed.

Report:

- files changed;
- mathematical changes;
- tests added/changed;
- test results;
- physics audit;
- complexity audit;
- remaining concerns.

## Git policy

Repair Mode does NOT automatically commit.

Do not:

- git reset --hard;
- git clean -f;
- force-push;
- delete branches;
- rewrite history.

The human user controls scientific commits.

The final response should provide the Git diff/status needed for human review.

## DVC policy

Agents may use:

- dvc add;
- dvc push;

when required by the repository workflow.

Agents must not use:

- dvc gc;
- dvc destroy;
- destructive DVC removal operations.

Never access credentials in:

.dvc/config.local

## Completion Boundary

Repair Mode ends after:

- implementation;
- tests;
- independent physics audit;
- complexity audit;
- Git diff review.

Do not automatically commit.

The user decides when the scientific state is ready to commit.
