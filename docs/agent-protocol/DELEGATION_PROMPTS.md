# KitaevDerivation.jl — Delegation Prompts

These prompts are intended for the `kitaev-architect` to pass to specialist
subagents.

---

## 1. Repository Audit

You are auditing an existing scientific Julia repository.

Do not modify files.

Determine:

1. current module dependency graph;
2. symbolic representation;
3. basis conventions;
4. projector conventions;
5. existing physical tests;
6. existing reference-paper assumptions;
7. potential symbolic-complexity bottlenecks;
8. current Git/DVC boundary.

Pay particular attention to whether the code already distinguishes:

    P_[L=0]
    P_[L=1]
    P_[L=2]

from:

    P_low
    P_hole
    P_half

Return a compact architectural report and identify the safest first phase.

---

## 2. BasisAndAlgebra Implementation

Implement only `BasisAndAlgebra.jl`.

Requirements:

CAR:

    {c_a,c_b†} = delta_ab
    {c_a,c_b} = 0
    {c_a†,c_b†} = 0

Projectors:

    P^2 = P
    P_i P_j = 0 for i != j

Use Symbolics.jl / SymbolicUtils.jl.

No dense matrices.

No unrelated changes.

Do not modify tests.

Return mathematical transformations and complexity expectations.

---

## 3. BasisAndAlgebra Test Generation

Construct independent tests in `test/`.

Do not modify `src/`.

Encode the CAR and projector identities as exact symbolic tests.

Every test must identify whether it is:

    ALGEBRAIC
    PROJECTOR

Do not derive expected results from implementation internals.

---

## 4. SingleSiteSOC

Implement or audit `SingleSiteSOC.jl`.

Required:

    T-P equivalence
    t2g effective angular momentum
    SOC Hamiltonian
    j_eff states
    Kramers doublet

Required oracle:

    Delta_E_SOC = 3*lambda_SOC/2

Document all phase and sign conventions.

---

## 5. TwoSiteKanamori

Implement or audit `TwoSiteKanamori.jl`.

Do not construct or symbolically diagonalize a generic 15x15 dense matrix.

Use:

    P_[L=0]
    P_[L=1]
    P_[L=2]

with:

    DeltaE_[L=0] = U + 2*J_H
    DeltaE_[L=1] = U - 3*J_H
    DeltaE_[L=2] = U - J_H

Verify the corresponding projector-sector eigenvalue relations.

Keep these projectors semantically distinct from low-energy projection.

---

## 6. Schrieffer-Wolff

Implement only the constrained second-order perturbation engine.

Never globally expand:

    P_low H_t R H_t P_low

Use:

    right-to-left state action
    ->
    CAR reduction
    ->
    normal ordering
    ->
    immediate projection
    ->
    simplification
    ->
    accumulation

The resolvent should remain decomposed into the analytical Kanamori channels:

    P_[L=0] / DeltaE_[L=0]
    P_[L=1] / DeltaE_[L=1]
    P_[L=2] / DeltaE_[L=2]

---

## 7. Exchange Extraction

Implement extraction of exchange coefficients using Pauli traces.

Validate:

    Tr(sigma^alpha sigma^beta) = 2 delta_alpha,beta

Required physical tests:

    J(J_H=0) = 0
    K(J_H=0) = 0
    K(lambda_SOC=0) = 0
    J_xx = J_yy

Do not change conventions silently.

---

## 8. Physics Audit

Act as an adversarial referee.

Assume the implementation may be subtly wrong even if all tests pass.

Check:

- fermionic signs;
- operator ordering;
- projection order;
- Kanamori channel assignment;
- energy denominators;
- particle/hole conventions;
- SOC signs;
- Kramers phase conventions;
- bond conventions;
- point-group transformations;
- hidden assumptions;
- missing tests.

Do not modify source code in the first pass.

---

## 9. Complexity Audit

Determine whether the implementation accidentally causes:

- dense 15x15 symbolic diagonalization;
- unrestricted Schrieffer-Wolff expansion;
- giant AST construction;
- excessive repeated symbolic simplification;
- uncontrolled term multiplication.

Measure:

    term count
    AST size
    runtime
    allocations
    memory

Do not print complete symbolic expressions.

---

## 10. Execution

Execute only deterministic test/verification commands.

Preferred:

    scripts/run-tests.sh

Return:

    PASS / FAIL
    failed tests
    minimal error
    runtime
    memory, if measured

Do not return complete logs.

---

## 11. Lean Validation

Validate the generated symbolic rewrite certificate.

Do not reproduce giant Julia expressions.

Verify:

- CAR rewrites;
- projector identities;
- Kanamori substitutions;
- Pauli traces;
- algebraic equivalence.

Do not introduce unsupported axioms merely to force success.

---

# Phase transition rule

Never transition to the next phase solely because compilation succeeds.

The required decision is:

    IMPLEMENTED
    TESTED
    EXECUTED
    PHYSICS-AUDITED
    COMPLEXITY-AUDITED

Only then may the architect advance the phase.
