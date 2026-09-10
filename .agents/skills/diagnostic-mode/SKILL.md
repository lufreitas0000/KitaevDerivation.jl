---
name: diagnostic-mode
description: Read-only scientific diagnosis of a KitaevDerivation.jl phase or module before any implementation changes.
---

# Diagnostic Mode

## Purpose

Diagnostic Mode is a READ-ONLY workflow.

Its purpose is to determine what is currently implemented, what is mathematically correct, what is missing, what is broken, and what should be repaired.

The diagnostic phase MUST NOT modify source code, tests, configuration, documentation, Git state, or DVC state.

The final result is a diagnosis and a proposed repair plan.

## Activation

Activate this workflow whenever the user asks to:

- start diagnostic mode;
- diagnose a phase;
- audit a phase;
- inspect a module before fixing it;
- troubleshoot a phase without modifying it;
- perform a read-only scientific audit.

Examples:

"Start diagnostic mode for Phase 2A."

"Diagnose BasisAndAlgebra.jl."

"Audit Phase 2B before making changes."

## Phase Identification

Resolve the requested phase before acting.

Known phases:

Phase 1:
- BasisAndAlgebra.jl
- CAR
- normal ordering
- noncommutative multiplication
- projectors

Phase 2A:
- SingleSiteSOC.jl
- spin-orbit coupling
- jeff=1/2
- jeff=3/2
- exact energy splitting 3λ/2

Phase 2B:
- TwoSiteKanamori.jl
- d4 multiplet structure
- P_[L=0]
- P_[L=1]
- P_[L=2]
- Kanamori energies

Phase 3:
- SchriefferWolff.jl
- ExchangeExtraction.jl
- effective exchange
- Jackeli-Khaliullin cancellation
- λ_SOC → 0 limit
- bond symmetry

Phase 4:
- Lean validation
- bond distortions
- local potentials
- formal verification

If the target is ambiguous, make the smallest reasonable interpretation and state it explicitly.

## Required Diagnostic Procedure

### 1. Establish repository state

Inspect:

- relevant source files;
- relevant tests;
- module dependencies;
- current Git diff/status.

Do not modify anything.

Do not reset, clean, checkout, restore, commit, or otherwise alter Git state.

### 2. Understand the implementation

Determine:

- mathematical representation;
- data structures;
- symbolic representation;
- operator algebra;
- projector representation;
- assumptions;
- simplification rules;
- interfaces between modules.

### 3. Check project constraints

Explicitly verify compliance with AGENTS.md.

Pay particular attention to:

- no dense symbolic 15×15 d4 construction;
- no dense symbolic diagonalization;
- use of abstract P_[L=0], P_[L=1], P_[L=2];
- analytical Kanamori denominators;
- no unconstrained Schrieffer-Wolff operator expansion;
- sequential right-to-left state action;
- immediate projection to jeff=1/2;
- Symbolics.jl + SymbolicUtils.jl only.

### 4. Check mathematical invariants

Identify:

- invariants already tested;
- invariants tested incorrectly;
- missing invariants;
- assumptions that are not encoded.

Use exact symbolic identities whenever possible.

Never weaken an oracle merely to make the test pass.

### 5. Delegate independent analysis

When specialist subagents are available:

- test-generator:
  construct independent mathematical test/oracle requirements;

- execution-worker:
  run the relevant existing tests and report failures;

- physics-auditor:
  independently check physics and conventions;

- complexity-auditor:
  inspect symbolic-expression growth and computational hazards.

Do not ask implementation agents to modify files during diagnostic mode.

### 6. Complexity assessment

Look specifically for:

- expression-tree explosion;
- unnecessary expansion;
- dense matrix construction;
- repeated symbolic simplification;
- unconstrained operator products;
- accidental recursion;
- nontermination risks.

### 7. Produce a diagnosis

Return:

1. target phase;
2. current implementation;
3. current tests;
4. passing invariants;
5. failing invariants;
6. missing tests;
7. implementation bugs;
8. physics/convention risks;
9. complexity risks;
10. recommended repairs;
11. files that would need modification;
12. proposed verification procedure.

Clearly distinguish:

- confirmed bug;
- missing feature;
- missing test;
- physics concern;
- hypothesis requiring verification.

## Hard Boundary

Diagnostic Mode MUST remain read-only.

Do not:

- edit files;
- generate replacement code in the repository;
- modify tests;
- modify configuration;
- commit;
- push;
- run dvc gc;
- run dvc destroy;
- remove data;
- weaken tests.

The user must explicitly authorize transition to Repair Mode.
