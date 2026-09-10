# KitaevDerivation.jl — AGY Project Constitution

## Mission

`KitaevDerivation.jl` is a scientific symbolic-computation framework for
deriving an effective Kitaev/Heisenberg-type Hamiltonian from a microscopic
Hubbard–Kanamori model and reproducing established analytical results.

The repository must simultaneously satisfy:

1. mathematical correctness,
2. physical correctness,
3. symbolic-computation correctness,
4. software-engineering correctness,
5. reproducibility.

Passing ordinary unit tests is NOT sufficient evidence of physical correctness.

---

# 1. Canonical notation

## 1.1 Multiplet projectors

The orbital-angular-momentum multiplet projectors MUST be written as:

    P_[L=0]
    P_[L=1]
    P_[L=2]

when referring specifically to the Kanamori orbital-angular-momentum
projectors in source code, documentation, agent reports, or tests.

The square-bracket notation is intentional and distinguishes these
multiplet projectors from low-energy, hole-space, or Hilbert-space
projectors.

## 1.2 Low-energy projectors

Projectors onto physical Hilbert subspaces must use an explicitly different
semantic name, for example:

    P_hole
    P_low
    P_half
    P_j_eff_1_2

Do not overload `P_[L=*]` for low-energy projection.

---

# 2. Computational prohibition: dense symbolic diagonalization

The two-hole d^4 virtual manifold contains 15 states.

Agents MUST NOT solve the physical derivation by constructing and symbolically
diagonalizing a generic dense 15 x 15 Hamiltonian.

The canonical representation is instead:

    P_[L=0]
    P_[L=1]
    P_[L=2]

with analytical Kanamori energies:

    DeltaE_[L=0] = U + 2*J_H
    DeltaE_[L=1] = U - 3*J_H
    DeltaE_[L=2] = U - J_H

The implementation may use explicit small matrices only for independent
validation or numerical cross-checks.

Dense symbolic eigensystem solving is not an acceptable primary algorithm.

---

# 3. Computational prohibition: unrestricted Schrieffer-Wolff expansion

Do not blindly expand:

    P_low * H_t * R * H_t * P_low

into unrestricted products of fermionic operators.

The preferred evaluation strategy is:

    right-to-left state action
        ->
    CAR reduction
        ->
    normal ordering
        ->
    immediate projection
        ->
    symbolic simplification
        ->
    accumulation of surviving amplitudes

Intermediate terms which are guaranteed to vanish must be eliminated as early
as possible.

---

# 4. CAS boundary

The main symbolic AST must use:

    Symbolics.jl
    SymbolicUtils.jl

Do NOT introduce `QuantumAlgebra.jl` into the primary symbolic pipeline
without explicit architectural approval from the architect agent.

The project should maintain one coherent symbolic representation.

---

# 5. Mathematical invariants

The following are first-class project requirements.

## CAR

    {c_a, c_b†} = delta_ab
    {c_a, c_b} = 0
    {c_a†, c_b†} = 0

## Projector algebra

For relevant orthogonal projectors:

    P^2 = P

and for distinct mutually exclusive sectors:

    P_i P_j = 0,  i != j

Completeness must be explicitly defined for the particular Hilbert-space
decomposition being used.

## Kanamori multiplets

    H_K P_[L=0] = (U + 2 J_H) P_[L=0]
    H_K P_[L=1] = (U - 3 J_H) P_[L=1]
    H_K P_[L=2] = (U - J_H) P_[L=2]

## SOC

The single-site implementation must reproduce the required
j_eff = 1/2 and j_eff = 3/2 structure and the specified symbolic
energy splitting:

    Delta_E_SOC = 3*lambda_SOC/2

## Physical limits

At J_H = 0:

    J = 0
    K = 0

In the non-relativistic limit:

    lambda_SOC -> 0

the anisotropic Kitaev exchange must vanish:

    K = 0

## Point-group symmetry

For the specified C_2 operation on a z bond exchanging x and y:

    J_xx = J_yy

All convention choices must be documented.

---

# 6. Mathematical TDD classification

Every test must identify its category.

Accepted categories:

    ALGEBRAIC
    PROJECTOR
    PHYSICAL_ORACLE
    LIMIT
    SYMMETRY
    REGRESSION
    NUMERICAL_CROSSCHECK
    COMPLEXITY

Tests MUST be derived from independent mathematical or physical facts.

Do not derive an oracle solely from the implementation under test.

---

# 7. Agent separation of responsibility

The following responsibilities are mandatory.

ARCHITECT
    Owns phase gates, architecture, delegation and conflict resolution.

PHYSICS IMPLEMENTER
    Implements symbolic physics in source modules.

TEST GENERATOR
    Creates independent mathematical-physics tests.

EXECUTION WORKER
    Runs tests, linters and controlled diagnostics.

PHYSICS AUDITOR
    Adversarially reviews implementations without assuming they are correct.

COMPLEXITY AUDITOR
    Monitors symbolic growth, memory, term counts and runtime.

LEAN VERIFIER
    Validates generated proof certificates independently where applicable.

---

# 8. Independence rule

The implementation agent and physics auditor must be treated as
epistemically independent.

The auditor must NOT simply repeat the implementation agent's reasoning.

A green test suite does not automatically imply:

    mathematically correct
    physically correct
    convention-independent
    computationally scalable

---

# 9. Context protection

Agents MUST NOT print:

- complete symbolic ASTs,
- giant expression expansions,
- complete generated datasets,
- huge raw logs,
- complete intermediate tensor products.

Diagnostics must be summarized.

Execution workers should return:

- failing test names,
- essential assertion values,
- minimal stack traces,
- runtime,
- memory information when relevant.

---

# 10. Git / DVC boundary

Git tracks:

    src/
    test/
    lean/
    docs/
    *.dvc
    Project.toml
    Manifest.toml

DVC tracks:

    data/
    large symbolic AST dumps
    large expression trees
    large numerical cross-validation datasets

Agents MAY use:

    dvc add
    dvc push

Agents MUST NEVER execute:

    dvc gc
    dvc destroy

Credential material such as:

    .dvc/config.local

must never be modified, committed, or printed.

---

# 11. Phase graph

Phase 1:

    BasisAndAlgebra.jl

Phase 2A:

    SingleSiteSOC.jl

Phase 2B:

    TwoSiteKanamori.jl

Phase 3:

    SchriefferWolff.jl
    ExchangeExtraction.jl

Phase 4:

    Lean verification
    bond distortions
    Gamma / Gamma'
    DM
    local potentials

Phase 2A and Phase 2B may proceed in parallel only after Phase 1 passes.

Phase 3 must NOT begin until Phase 1 and Phase 2 acceptance gates pass.

Phase 4 must NOT modify the stable derivation silently.

---

# 12. Definition of done

A phase is complete only when all applicable conditions are satisfied:

1. source implementation exists;
2. mathematical documentation exists;
3. independent tests exist;
4. execution succeeds;
5. physical oracle audit passes;
6. symbolic-complexity behavior is acceptable;
7. no forbidden computational strategy was introduced;
8. architecture remains compatible with downstream phases.

---

# 13. Agent reporting contract

Every subagent must return:

    STATUS
    SCOPE
    FILES_CHANGED
    MATHEMATICAL_CLAIMS
    PHYSICAL_CLAIMS
    TEST_STATUS
    COMPLEXITY_STATUS
    UNCERTAINTIES
    RECOMMENDED_NEXT_STEP

Do not return giant generated expressions.

---

# 14. Stop conditions

Any agent must STOP and report to the architect when:

- a sign convention is ambiguous;
- a basis convention is unclear;
- a requested identity conflicts with an existing invariant;
- symbolic growth becomes unexpectedly large;
- a dense symbolic diagonalization appears necessary;
- the physical oracle appears inconsistent;
- a test appears to encode the implementation instead of independent physics;
- a destructive repository operation would be required.

Do not weaken the physical invariant merely to obtain a green test.
