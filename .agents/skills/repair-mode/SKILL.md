---
name: repair-mode
description: Autonomous controlled implementation and verification workflow for an approved scientific repair scope.
---

# Repair Mode

## Purpose

Repair Mode allows autonomous implementation of a previously diagnosed
scientific/software problem.

The objective is to delegate implementation and verification without requiring
the human to approve every routine file edit.

Autonomy is granted within an explicitly defined repair scope.

The agent MUST stop and request human intervention only when it reaches a
boundary defined below.

---

# 1. Activation

Activate Repair Mode when the user explicitly asks to:

- start repair mode;
- repair/fix a diagnosed phase;
- implement the diagnostic findings;
- proceed with the approved repair.

Examples:

"Start repair mode for Phase 1."

"Proceed with the Phase-1 repair."

"Fix the issues identified in the Phase-1 diagnostic."

If no diagnostic exists, perform a diagnostic before making broad changes.

---

# 2. Establish the Repair Scope

Before making modifications, determine the repair scope from:

1. the user's request;
2. the latest diagnostic findings;
3. AGENTS.md;
4. the relevant phase definition;
5. existing tests and module dependencies.

Create an internal repair scope containing:

- approved source files;
- approved test files;
- approved configuration files;
- approved types of changes;
- explicit forbidden operations.

The scope should be reported briefly at the beginning of Repair Mode.

Do NOT ask for approval merely to establish this scope when it is directly
specified by the user's repair request and the diagnostic.

---

# 3. Autonomous Work Inside Scope

Once the repair scope is established, the implementation agents may work
AUTONOMOUSLY inside that scope.

Routine edits do NOT require human approval.

The following operations are normally AUTO-APPROVED when they remain inside
the repair scope:

- fixing syntax errors;
- fixing obvious typographical errors;
- correcting imports;
- adding required dependencies;
- adding comments;
- adding or improving docstrings;
- formatting code;
- implementing functions specified by the diagnostic;
- correcting implementation bugs identified by the diagnostic;
- adding mathematical tests;
- adding regression tests;
- correcting tests that are demonstrably incorrect;
- adding test fixtures;
- running Julia tests;
- running static analysis;
- running formatting checks;
- inspecting Git status/diff;
- reading source files;
- reading tests;
- creating temporary diagnostic files;
- performing non-destructive DVC operations required by the workflow.

Do not stop for approval for each individual Edit.

---

# 4. Scientific Boundaries

Autonomy does NOT imply permission to change scientific meaning.

The agent MUST STOP and request human intervention before making any of the
following changes unless the diagnostic explicitly included them:

- changing a physical convention;
- changing basis conventions;
- changing sign conventions;
- changing normalization conventions;
- changing the definition of an operator;
- changing the definition of a projector;
- weakening or deleting a physical oracle;
- replacing an exact symbolic identity with a numerical approximation;
- changing a mathematical invariant;
- introducing a new approximation;
- changing the representation of a physical Hilbert space;
- changing analytical Kanamori energies;
- changing the meaning of P_[L=0], P_[L=1], or P_[L=2];
- introducing dense symbolic d4 matrices;
- introducing symbolic diagonalization of the 15x15 d4 space;
- expanding unconstrained Schrieffer-Wolff fermionic operator products.

When such a boundary is reached:

1. stop the affected operation;
2. explain why the change is necessary;
3. show the proposed change;
4. request human authorization.

Do not continue by silently choosing a convention.

---

# 5. File-Scope Boundary

Agents may autonomously modify files explicitly included in the repair scope.

If a required change appears in a file outside the scope:

1. determine whether it is genuinely required;
2. do NOT modify it immediately;
3. report the file and reason;
4. request authorization to extend the scope.

Example:

Phase 1 repair scope:

    src/BasisAndAlgebra.jl
    test/test_algebra.jl
    Project.toml

If implementation discovers that:

    src/TwoSiteKanamori.jl

must change, do not silently edit it.

Report:

    "Phase-1 repair requires a change to TwoSiteKanamori.jl because ..."

Then request authorization to extend the scope.

This prevents accidental repository-wide refactoring.

---

# 6. Test Policy

Tests are part of the scientific contract.

Agents may autonomously:

- add missing tests;
- add regression tests;
- correct tests whose assumptions contradict the documented mathematics;
- run targeted tests;
- run phase-level tests;
- run the full test suite.

Agents MUST NOT weaken an oracle merely to make a failing implementation pass.

If an existing test appears mathematically wrong, stop and report:

- current test;
- mathematical reason it appears wrong;
- proposed replacement;
- expected consequence.

Do not silently weaken or delete the test.

---

# 7. Mathematical Oracles

Preserve and enforce the following project invariants.

## Phase 1

CAR:

    {cα, cβ†} = δαβ
    {cα, cβ} = 0
    {cα†, cβ†} = 0

Projectors:

    P_i² = P_i

    P_i P_j = 0     for i ≠ j

Do not replace exact symbolic identities with approximate numerical checks
when an exact symbolic check is possible.

## Phase 2A

Verify the jeff=1/2 and jeff=3/2 construction and the exact energy gap:

    ΔE = 3λ/2

## Phase 2B

Use abstract multiplet projectors:

    P_[L=0]
    P_[L=1]
    P_[L=2]

and analytical energies:

    ΔE0 = U + 2 J_H
    ΔE1 = U - 3 J_H
    ΔE2 = U - J_H

Do not construct or diagonalize dense symbolic 15x15 d4 matrices.

## Phase 3

Preserve:

    J_H = 0  =>  J = K = 0

    λ_SOC → 0  =>  K → 0

and for a z bond:

    J_xx = J_yy

Do not expand unconstrained Schrieffer-Wolff operator products.

---

# 8. Complexity Policy

Agents may optimize implementation autonomously when the optimization is
semantics-preserving.

Agents MUST stop before introducing:

- dense symbolic matrices;
- symbolic 15x15 diagonalization;
- uncontrolled expression expansion;
- uncontrolled fermionic operator products;
- exponential expression-tree growth;
- unnecessary repeated symbolic simplification.

Use sequential state action, normal ordering, and immediate projection when
required by the project architecture.

If the only apparent solution violates these constraints, stop and report the
problem.

---

# 9. Git Policy

Git inspection is allowed.

Agents may autonomously run:

    git status
    git diff
    git log

Agents MUST NOT automatically:

    git commit
    git push
    git reset --hard
    git clean -f
    git checkout -- <files>
    git restore --worktree
    force-push
    delete branches destructively

The human controls scientific commits.

At the end of Repair Mode, show:

    git status
    git diff --stat
    git diff

when practical.

---

# 10. DVC Policy

Agents may autonomously use:

    dvc add
    dvc push

when required by the explicitly approved workflow.

Agents MUST NEVER autonomously use:

    dvc gc
    dvc destroy

or destructive DVC removal operations.

Never access:

    .dvc/config.local

---

# 11. Verification Workflow

After implementation:

1. run targeted tests;
2. run phase-level tests;
3. run the complete test suite when practical;
4. run physics audit;
5. run complexity audit;
6. inspect Git diff;
7. confirm no unintended files changed.

If tests fail:

- diagnose the failure;
- fix the implementation if the fix is clearly within scope;
- do not weaken the test;
- repeat verification.

If a failure indicates a scientific ambiguity rather than a coding bug,
stop and request human input.

---

# 12. Unexpected Changes

If implementation discovers a necessary change outside the approved scope,
DO NOT silently expand the repair.

Stop only the affected work and report:

    File:
    Why it is required:
    Proposed change:
    Scientific impact:
    Tests affected:

Request authorization to extend the repair scope.

Routine changes within scope should continue autonomously.

---

# 13. Completion

Repair Mode is complete when:

- approved implementation changes are applied;
- relevant tests pass;
- physics audit passes;
- complexity audit passes;
- unintended changes are absent;
- Git diff has been inspected.

Do NOT commit.

Return a concise final report containing:

1. files changed;
2. implementation changes;
3. tests added/changed;
4. test results;
5. physics audit result;
6. complexity audit result;
7. remaining concerns;
8. Git status/diff summary.

---

# Core Principle

The agent is expected to work autonomously.

Human supervision is a BOUNDARY mechanism, not a step-by-step approval
mechanism.

Routine implementation inside an explicitly approved scientific scope should
proceed without interruption.

Human intervention is required only for:

- scientific meaning changes;
- scope expansion;
- destructive operations;
- weakened mathematical guarantees;
- ambiguous physical conventions;
- irreversible repository operations.
