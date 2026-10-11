# Critical Architectural & Scientific Review — KitaevDerivation.jl
**Date:** 2026-09-12  
**Reviewer:** Antigravity Architect (adversarial diagnostic mode)  
**Status of reviewed codebase:** Phase 3 in progress, Phases 1–2 declared "100% SUCCESS"

---

## Executive Summary

The project sets out to derive the Kitaev-Heisenberg effective Hamiltonian from a microscopic
Hubbard-Kanamori model using a purely symbolic, non-matrix strategy implemented in Julia with
Symbolics.jl/SymbolicUtils.jl. The design philosophy is well-motivated and technically sound in
its motivations. **However, the current implementation contains a set of deep structural
contradictions that prevent it from being scientifically correct, regardless of test-suite color.**

> [!CAUTION]
> **The package fails to precompile on Julia 1.12.** The test run discovered a
> `Failed to precompile Symbolics` error during `Pkg.test()`. The test suite is
> **not passing at all** — it cannot even load. This means the roadmap claim of
> "Phase 1 & 2: 100% SUCCESS" is asserted against a test suite that may not have
> been run against the current Julia version.

The core finding: **the architecture has drifted into a dual-representation crisis.** The symbolic
AST layer (Phases 1–2) and the numerical state-evaluation layer (Phase 3) are epistemically
incompatible, and their interface is never closed. The project is trying to simultaneously be a
CAS rewriting engine and a numerical state evaluator — and in the critical Phase 3 path it
silently falls back to the latter while the roadmap declares the former as complete.

This review is structured as: (1) big-picture architectural critiques, (2) specific technical
defects, (3) a scientific correctness audit of the physical claims, (4) a verdict on solvability,
and (5) a proposed pivot strategy.

---

## Part I — Big-Picture Architectural Problems

### Problem 0 — Package Does Not Precompile on Current Julia

**Severity: CRITICAL (blocks everything)**

Running `julia --project=. -e 'using Pkg; Pkg.test()'` produces:

```
ERROR: LoadError: Failed to precompile Symbolics [0c5d862f...] 
  to ".julia/compiled/v1.12/Symbolics/..."
```

The failure occurs inside `~/.julia/packages/Symbolics/Eas9m/src/Symbolics.jl`. This is a
compatibility breakage between the pinned `Symbolics = "5.5"` in `Project.toml` and the
running Julia version (1.12). The roadmap claims "Phase 1 & 2: 100% SUCCESS" — but if the
package cannot be loaded, no test can have run on this environment. The test results the
roadmap is based on may come from a different (older) Julia environment.

**Required action:** Update `Project.toml` compat bounds, run `Pkg.update()`, and verify
all tests still pass against the current installed Julia version before any scientific claims
are made about test status.

---

### Problem 1 — Dual-Representation Crisis: The AST Engine Stops at Phase 2

**Severity: CRITICAL**

Phase 1 and Phase 2 implement an abstract symbolic AST:
- `FermionC`, `FermionA`, `MultipletProjector`, `OperatorString`, `OperatorSum`
- Rules: `apply_algebraic_rules`, `sort_normal_order`, `commutator`, `anticommutator`

The **stated goal** of this AST is to avoid matrix construction and enable symbolic rewriting.

Phase 3 (`ExchangeExtraction.jl`) **silently abandons the symbolic AST** and replaces it with a
**numerical Fock-space state evaluator** (`apply_fermion_c`, `apply_fermion_a`,
`apply_multiplet_projector`). These functions operate on:

```julia
Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}
```

This is **concrete numerical state evaluation**, not symbolic computation. The coefficients are
`ComplexF64`, not `Symbolics.Num`. This means:

1. The result of `project_to_pseudospin` is a **numerical matrix** of `ComplexF64` entries
   multiplied by symbolic scalars from the resolvent denominators.
2. The symbolic parameters `U`, `J_H`, `lambda_soc` are never propagated through the
   state-evaluation logic.
3. The `d4_basis` dictionary in `ExchangeExtraction.jl` is a **hardcoded set of numerical
   basis state coefficients** (`1/sqrt(3)`, etc.).

**Consequence:** The symbolic rewriting strategy is abandoned at exactly the most physically
critical point. The Schrieffer-Wolff engine (`SchriefferWolff.jl`) produces `OperatorString`
objects, but `project_to_pseudospin` evaluates them numerically against hardcoded basis states.
This means the output coefficients are **numerically assembled, not symbolically derived**.

This is not wrong in principle — but it is architecturally inconsistent with the Phase 1/2
design and with the stated AGENTS.md constraints ("right-to-left state action → CAR reduction →
normal ordering → immediate projection → symbolic simplification").

---

### Problem 2 — The SOC Variable `lambda_soc` is Phantom

**Severity: CRITICAL**

The `project_to_pseudospin` function signature accepts `lambda_soc::Any=Inf` but this parameter
is **never used inside the function body**. The Kramers doublet basis used in `pseudospin_ket`
is hardcoded for the infinite-SOC limit:

```julia
# get_doublet_coeff hardcodes j_eff=1/2 coefficients
# independently of any lambda_soc value
```

`software_snapshot.md` acknowledges this:
> "Attempting to take the λ_SOC → 0 limit after projection into the infinite-λ_SOC manifold is
> a mathematical contradiction."

This is partially correct in motivation but has two critical problems:

1. **The non-relativistic limit oracle in AGENTS.md (`λ_SOC → 0 ⇒ K = 0`) is declared
   mandatory but is simultaneously admitted to be untestable.** The AGENTS.md
   specification and the implementation are in direct contradiction. The roadmap declares Phase 2A
   "100% SUCCESS" for the SOC module, but the physical oracle `K = 0` at `λ_SOC = 0` is
   unreachable.

2. **The `test_exchange.jl` does NOT test the Jackeli-Khaliullin oracle `J_H = 0 ⇒ J = K = 0`
   at all.** It tests a "Non-Zero Oracle" (`|K| > 1e-6` at finite parameters) and that `J_xx = 0`
   when `t_prime = 0` — which is a weaker statement about the t' hopping, not about Hund's
   coupling.

---

### Problem 3 — The Schrieffer-Wolff Engine is Disconnected from Exchange Extraction

**Severity: CRITICAL**

`SchriefferWolff.jl::compute_effective_hamiltonian` produces an `OperatorSum` where each term is:
```
ScaledOperator(scalar, OperatorString([P1_j, c†, c, P_[L=k], c†, c, P_[L=k], ...]))
```

containing `MultipletProjector` nodes.

`ExchangeExtraction.jl::project_to_pseudospin` calls `evaluate_string` on these
`OperatorString` nodes, which in turn calls `apply_multiplet_projector`. But
`apply_multiplet_projector` expects the state (a `Dict` of kets) to have exactly 2 particles
at the target site — the `d4` intermediate state. However, the initial ket from
`pseudospin_ket` contains **one particle per site** (the `d5` ground state, with 1 hole). 

This means: **when the MultipletProjector is encountered in `evaluate_string`, the site
particle count check `length(site_particles) != 2` will silently `continue`**, dropping
the projector's action entirely and returning an empty state instead of the projected state.

This is a structural bug where the `d4` multiplet projector is being applied to the wrong
Hilbert subspace. The operator string produced by the Schrieffer-Wolff engine has already
"expanded" the `ParticleProjector(2)` into `MultipletProjector` objects — but the state
evaluator in `ExchangeExtraction.jl` is not aware of this substitution.

---

### Problem 4 — `KineticHopping.jl` Uses Potentially Wrong Projector-Fermion Ordering

**Severity: HIGH**

The operators `build_T1_operator` and `build_Tm1_operator` construct:

```julia
OperatorString([P2_i, c†_i, c_j, P1_j])   # T1: [P^(2), c†, c, P^(1)]
OperatorString([P1_i, c†_i, c_j, P2_j])   # Tm1
```

The structure `P^(2)_i c†_i` puts the particle projector to the LEFT of the creation operator.
In the physical second-quantization formalism, `T1` that creates a `d4` virtual state on site
`i` should apply the creation operator and THEN the projector projects the resulting state.
The `apply_algebraic_rules` Rule 3 (Fermion-Projector Intertwining) is designed to commute
them, but this rule only handles `ParticleProjector`, not `MultipletProjector`. The
intertwining identity is never applied to the concatenated Schrieffer-Wolff strings.

Additionally, in the t'=0 case the hopping matrix is:

```julia
# z-bond: mat[1,2]=mat[2,1]=t  (xy-channels)
# mat[3,3]=t_prime
```

If t'=0, the `P^(2)_i c†_{i,z} c_{j,z} P^(1)_j` term should NOT appear (there is no diagonal
hopping), but the `P^(2)_i c†_{i,x} c_{j,y} P^(1)_j` and `P^(2)_i c†_{i,y} c_{j,x} P^(1)_j`
terms DO appear. This is physically correct for a z-bond.

---

### Problem 5 — Phase Gate Violations

**Severity: HIGH**

The roadmap declares:
- **Phase 1: 100% SUCCESS** — but contains no test for `SpinComposite`, `OrbitalComposite`,
  `GenericOp`, or `ParticleProjector` type interplay.
- **Phase 2A: 100% SUCCESS (SOC)** — but `project_jeff_half` never actually evaluates the
  SOC Hamiltonian symbolically; it pattern-matches against a freshly-constructed `H_so` using
  `==` equality. Since `OperatorSum` equality requires exact structural match (not symbolic
  equivalence), the `soc_projection_rules` match in `project_jeff_half` is fragile and
  non-compositional.
- **Phase 2B: 100% SUCCESS (Kanamori)** — the Kanamori multiplet projectors are declared as
  symbolic labels but are never proven to be idempotent or orthogonal in a concrete Hilbert
  space. Tests only verify that `apply_algebraic_rules` returns the right abstract token.

The AGENTS.md definition of "done" (Section 12) requires:
> "physical oracle audit passes; symbolic-complexity behavior is acceptable"

Neither is explicitly verified for Phases 1 and 2.

---

### Problem 6 — The `d4_basis` in `ExchangeExtraction.jl` is an Undocumented Hardcode

**Severity: HIGH**

The function `_make_d4()` builds the Kanamori multiplet basis states as:

```julia
push!(L0, Dict(p(:x,:down, :x,:up, 1/sqrt(3)), p(:y,:down, :y,:up, 1/sqrt(3)), ...))
push!(L1, Dict(p(o1,:up, o2,:up, 1.0)))
...
```

These are the Clebsch-Gordan coefficients for the two-hole d4 manifold. They are:
1. **Hardcoded** as `Float64` constants — no symbolic representation.
2. **Not documented** with any mathematical derivation or literature reference.
3. **Not independently tested** — no test verifies that these states form an orthonormal
   set, span the correct subspace, or satisfy `H_K |ψ⟩ = ΔE_L |ψ⟩`.
4. **Not connected** to the symbolic `MultipletProjector` objects used in the AST.

This is precisely the dense representation the project claims to avoid. The `d4_basis`
dictionary effectively re-introduces the 15-state space in numerical form, contradicting the
design philosophy.

---

### Problem 7 — The `get_doublet_coeff` Basis Convention is Undocumented and Potentially Wrong

**Severity: HIGH**

The `j_eff = 1/2` Kramers doublet states are hardcoded in `get_doublet_coeff`:

```julia
# |+⟩ state (pspin == :up):
(orb == :z && rspin == :up)   && return 1.0     # |z,↑⟩
(orb == :x && rspin == :down) && return 1.0     # |x,↓⟩
(orb == :y && rspin == :down) && return 1im     # +i|y,↓⟩
```

This gives (unnormalized): `|z↑⟩ + |x↓⟩ + i|y↓⟩`

But `formal_derivation.md` documents:
```
|+⟩ = (1/√3)(-|z,↑⟩ - i|y,↓⟩ - |x,↓⟩)
```

**The sign of every component is flipped, and the imaginary phase of |y,↓⟩ is opposite.**

The normalization factor 1/√3 is absorbed into `pseudospin_ket` via `/3.0` (squared norm).
But the sign discrepancy would flip the phase of off-diagonal matrix elements, potentially
producing wrong signs for the Kitaev coupling `K` or Gamma terms. **No test currently
validates the Kramers doublet coefficients against the documented analytical form.**

---

### Problem 8 — Lean 4 Verification Layer is Effectively Empty

**Severity: MEDIUM (blocks Phase 6)**

`lean/Axioms.lean` contains scaffolding only:

```lean
-- Future integration: Axiomatize canonical anti-commutation relations (CAR)
-- {c_i, c_j^dag} = delta_ij
```

`lean/Main.lean` is empty (0 bytes). There is no mechanism to translate the Julia AST
rewriting steps into Lean proof certificates. The `docs/documentation_V1.0.0.md` discusses
Approaches A and B for Julia-to-Lean translation but neither has been started.

---

### Problem 9 — Test Suite Has Critical Coverage Holes

**Severity: HIGH**

**Missing tests:**
1. `test_cancellation.jl` — **Empty file (0 bytes).** The Jackeli-Khaliullin cancellation
   oracle (`J_H = 0 ⇒ J = K = 0`) has **no test implementation**. This is the most
   fundamental physical oracle for the entire derivation.
2. `test_symmetries.jl` — **Empty file (0 bytes).** The C2 point-group oracle (`J_xx = J_yy`
   on z-bond) has **no test implementation**.

**Weak or circular tests:**
- `test_schrieffer_wolff.jl` Oracle 2 asserts `length(H_eff.terms) == 3` after applying
  `compute_effective_hamiltonian`. This assertion passes vacuously if the orthogonal pruning
  is NOT working — because orthogonal channel pruning does not happen at the SW level, only
  at the state-evaluation level.
- `test_soc.jl` SOC energy gap test verifies `soc_projection_rules` via pattern match.
  The expected result is generated by the same function as the rule, making it
  implementation/test circular.

---

## Part II — Specific Technical Defects

### Defect T1 — `ParticleProjector.holes` Semantics are Inverted in ExchangeExtraction

`BasisAndAlgebra.jl` names the field `holes::Int` (d4 = 2 holes). But
`apply_particle_projector` in `ExchangeExtraction.jl` filters:
```julia
count(x -> x[1] == p.site, kets) == p.holes
```
This counts **particles** at the site from the ket vector. The semantic is `particles == holes`
— which is only correct if the ket is stored in the hole picture where `holes=1` means 1
particle. This is never documented. If the ket representation changes, this will silently fail.

### Defect T2 — `apply_resolvent` Ignores the Low-Energy Projector `P_low`

The canonical Schrieffer-Wolff formula is:
```
H_eff = P_low · T_{-1} · R · T_1 · P_low
```

`compute_effective_hamiltonian` computes `T_{-1} · R · T_1` but **never applies `P_low`**.
The projection onto `j_eff=1/2` subspace happens implicitly in `project_to_pseudospin` only
by evaluating matrix elements with doublet basis states. The SW output is NOT bounded by the
low-energy subspace — it includes virtual transitions that should vanish when sandwiched by
`P_low`.

### Defect T3 — `Tm1` Transposition Comment Hides Future Bug

In `build_Tm1_operator`:
```julia
val = T_mat[idx_b, idx_a]   # "Utilizing the transposed matrix... T is symmetric for NN bonds"
```
For the `t` hopping this is harmless. But for `t_prime` (diagonal), transposition is identity.
**For any future non-symmetric hopping geometry this will silently produce wrong results**
without any test to catch it.

### Defect T4 — `evaluate_pauli_trace` Has Type Instability

`evaluate_pauli_trace(op::SpinComposite)` returns `Int(0)`, while the 3-factor branch returns
`Complex{Float64}`. This type instability in the accumulation loop can cause silent promotions.
The `len == 1` branch is also missing — a single Pauli matrix has `Tr(σ) = 0` which falls
through correctly, but via an undocumented path.

### Defect T5 — `collect_terms` Uses Syntactic Equality for Collecting

`collect_terms` groups terms with the same `OperatorString` using Julia's `==`, which requires
exact syntactic equality. **Terms that are symbolically equal but syntactically different
(e.g. different normal ordering) will NOT be combined**, preventing cancellations from being
detected. After `sort_normal_order`, identical physical states may appear in different forms.

---

## Part III — Scientific Correctness Audit

### S1 — Is the Physical Derivation Strategy Sound?

**Yes.** The Jackeli-Khaliullin derivation proceeds correctly in principle:
1. Half-filled d5 ground state + strong SOC → j_eff=1/2 doublets
2. Virtual hopping → d4 intermediate states (Kanamori multiplets)
3. Second-order Schrieffer-Wolff → effective exchange
4. Project to j_eff=1/2 → extract J, K, Γ tensors

The decision to avoid 15×15 symbolic diagonalization and use abstract multiplet projectors
is well-motivated and consistent with the literature.

### S2 — Is the Current Approach Sufficient?

**Partially.** The approach CAN derive:
- Second-order Kitaev/Heisenberg exchange in the **strong SOC limit** (λ → ∞)
- For the **symmetric nearest-neighbor hopping** geometry
- With **analytical Kanamori multiplet denominators**

This corresponds to the original Jackeli-Khaliullin result.

The approach CANNOT derive (without significant architectural changes):
- λ_SOC → 0 limit (excluded by infinite-SOC basis choice)
- Γ, Γ' at finite trigonal distortion (requires finite SOC in resolvent)
- DM interaction (requires inversion-breaking in energy denominators)
- Third-order three-site exchange (new Hilbert-space sector)
- Formal Lean verification (Julia-to-Lean bridge undefined)

**The roadmap is over-scoped relative to the chosen architecture.**

### S3 — The Key Formula — Can It Be Produced Correctly?

The Jackeli-Khaliullin Kitaev coupling:
```
K = -8J_H t² / [3(U - 3J_H)(U - J_H)]
```
can in principle be extracted from the numerical matrix elements once the basis states and
operator pipeline are correct. But:
1. The Kramers doublet signs appear wrong (Problem 7).
2. The d4 Clebsch-Gordan coefficients are unvalidated (Problem 6).
3. The operator pipeline interface is broken (Problem 3).

**None of the three prerequisites are currently verified.**

### S4 — What the Tests Actually Prove

| Claim | Test exists? | Independent? | Conclusion |
|-------|-------------|-------------|------------|
| CAR algebra correct | Yes (`test_algebra.jl`) | Yes | VERIFIED |
| Projector idempotency (abstract) | Yes (`test_kanamori.jl`) | Yes | VERIFIED (abstract only) |
| Kanamori eigenvalues correct | Yes | Yes | VERIFIED |
| SOC energy gap 3λ/2 | Yes (`test_soc.jl`) | Circular | WEAK |
| d4 basis states correct | No | N/A | **MISSING** |
| Kramers doublet signs correct | No | N/A | **MISSING** |
| J_H=0 ⟹ J=K=0 | No (empty file) | N/A | **MISSING** |
| λ→0 ⟹ K=0 | Not possible | N/A | **ARCHITECTURALLY EXCLUDED** |
| J_xx = J_yy (C2) | No (empty file) | N/A | **MISSING** |
| K formula matches literature | No | N/A | **MISSING** |

---

## Part IV — Can the Problem Be Solved by the Current Approach?

**Verdict: Yes, with a precisely delimited scope and concrete repairs.**

The problem IS solvable for:
- The Jackeli-Khaliullin result (K, J at strong SOC, symmetric hopping)
- The J_H=0 and C2 symmetry oracles
- The full symbolic/numerical hybrid pipeline producing `K = -8J_H t² / [3(U-3J_H)(U-J_H)]`

The problem is NOT solvable without new architecture for:
- λ_SOC → 0 limit (would require working with the full finite-SOC 6×6 single-site space)
- Trigonal distortion Γ, Γ' physics (same reason)
- DM interaction (same reason)
- Phase 6 Lean verification (no bridge mechanism defined)

---

## Part V — Proposed Pivot Strategy

### Pivot 1 — Immediately Fix the Precompilation Failure

```bash
julia --project=. -e 'using Pkg; Pkg.update(); Pkg.resolve()'
```

Pin to a working Symbolics.jl version or upgrade compat bounds in `Project.toml`. Verify
all existing tests pass before any further work.

### Pivot 2 — Choose and Commit to One Representation

Choose **one** of these architectures:

**Option A: Pure Symbolic (faithful to AGENTS.md spirit)**
- Replace `ComplexF64` ket dictionaries in `ExchangeExtraction.jl` with `Symbolics.Num` dicts.
- Allows λ_SOC as a free symbol. Cost: higher complexity.

**Option B: Numerical-Symbolic Hybrid (recommended — faster to correct results)**
- Acknowledge that j_eff=1/2 projection uses hardcoded numerical doublet coefficients.
- Document this as a deliberate strong-SOC limit choice.
- Remove the phantom `lambda_soc` parameter from all function signatures.
- Remove the λ→0 oracle from AGENTS.md mandatory list (or reclassify as Phase 5+).
- Add NUMERICAL_CROSSCHECK tests validating K, J against known analytical results.

**Recommendation: Option B.** The project should stop claiming to be purely symbolic when
the critical projection step is numerical.

### Pivot 3 — Validate the Physical Basis States (Day 1 Priority)

Write an independent NUMERICAL_CROSSCHECK test:
```julia
@testset "[NUMERICAL_CROSSCHECK] d4 basis and Kramers doublet validation"
    # 1. Build 15x15 Kanamori H explicitly (allowed for crosscheck per AGENTS.md §2)
    # 2. Diagonalize numerically
    # 3. Compare eigenstates to d4_basis entries
    # 4. Compare j_eff=1/2 doublet to formal_derivation.md formula with correct signs
end
```

### Pivot 4 — Fix the Operator Pipeline Interface

The operator string produced by `compute_effective_hamiltonian` must be processable by
`evaluate_string`. Restructure `project_to_pseudospin` to apply operator strings in stages:
1. Apply T_1 to d5 initial ket → d4 intermediate state
2. Apply MultipletProjector + energy denominator to d4 state
3. Apply T_{-1} to d4 state → d5 final state
4. Compute overlap with d5 bra state

This is the correct right-to-left state-action strategy described in AGENTS.md §3.

### Pivot 5 — Implement the Two Mandatory Empty Test Files

These are the highest-priority scientific obligations in the entire project:

**`test_cancellation.jl`:**
```julia
@testset "[PHYSICAL_ORACLE] Jackeli-Khaliullin: J_H=0 ⟹ J=K=0"
    tensors = extract_exchange_tensors(...)
    @test isequal(simplify(substitute(tensors[:K], J_H => 0)), 0)
    @test isequal(simplify(substitute(tensors[:J], J_H => 0)), 0)
end
```

**`test_symmetries.jl`:**
```julia
@testset "[SYMMETRY] C2 rotation z-bond: J_xx = J_yy"
    @test isequal(simplify(tensors[:J_xx] - tensors[:J_yy]), 0)
end
```

### Pivot 6 — Reconcile the AGENTS.md Physical Oracles with Architecture

| Oracle | Current Status | Required Action |
|--------|---------------|-----------------|
| `λ_SOC → 0 ⇒ K = 0` | Architecturally excluded | Reclassify as Phase 5+ (finite-SOC basis) |
| `J_H = 0 ⇒ J = K = 0` | Testable but untested | Implement in `test_cancellation.jl` |
| `J_xx = J_yy` on z-bond | Testable but untested | Implement in `test_symmetries.jl` |
| `ΔE_SOC = 3λ/2` | Pattern-match tested | Needs independent basis derivation |
| `H_K P_[L] = ΔE_L P_[L]` | Symbolic tested | Needs numerical crosscheck |

---

## Part VI — Prioritized Action Plan

### Priority 1 — Immediate (blocks all downstream)
1. Fix Symbolics.jl precompilation (`Pkg.update()`). Verify existing tests actually run.
2. Validate `d4_basis` by 15×15 crosscheck (NUMERICAL_CROSSCHECK test).
3. Validate `get_doublet_coeff` signs against `formal_derivation.md`.
4. Implement `test_cancellation.jl` — J_H=0 oracle.
5. Implement `test_symmetries.jl` — C2 oracle.

### Priority 2 — Phase 3 correctness
6. Fix the Schrieffer-Wolff/ExchangeExtraction pipeline interface (Problem 3).
7. Remove phantom `lambda_soc` parameter; document strong-SOC limit explicitly.
8. Add `P_low` projection flanking in `compute_effective_hamiltonian`.

### Priority 3 — Architectural clarity
9. Choose Option A or B and commit to one representation.
10. Update AGENTS.md §5 to reflect λ_SOC → 0 oracle limitation.
11. Downgrade roadmap Phase 2A status to "SUCCESS (strong-SOC limit)" with explicit caveat.

### Priority 4 — Long-term (Phase 4+)
12. Plan finite-SOC architecture for Γ, Γ', DM physics.
13. Define Julia-to-Lean certificate mechanism before starting Lean work.

---

## Appendix — File-Level Summary

| File | Role | Status | Critical Issue |
|------|------|--------|----------------|
| `BasisAndAlgebra.jl` | Symbolic AST engine | Functionally correct | Rule 3 only handles `ParticleProjector` |
| `AuxiliaryOperators.jl` | Composite types | Minimal | No dedicated tests |
| `SingleSiteSOC.jl` | SOC projection | Pattern-match only | Not a real symbolic evaluation |
| `TwoSiteKanamori.jl` | Multiplet projectors | Correct (abstract) | Basis states absent |
| `KineticHopping.jl` | Hopping operators | Structurally OK | Projector ordering unverified |
| `SchriefferWolff.jl` | SW engine | Structurally partial | Missing P_low flanking |
| `ExchangeExtraction.jl` | State evaluation | Dual-representation | Numerical; hardcoded basis; sign dispute |
| `test_cancellation.jl` | **Physical oracle** | **EMPTY** | J-K cancellation missing |
| `test_symmetries.jl` | **Physical oracle** | **EMPTY** | C2 symmetry missing |
| `lean/Axioms.lean` | Formal verification | Stub | No functional proofs |
| `lean/Main.lean` | Lean entry | **EMPTY** | No implementation |

---

## Conclusion

The project is scientifically viable and the fundamental approach is well-motivated. The
problem IS solvable, but **only for the strong-SOC Jackeli-Khaliullin result** — the roadmap's
Phase 4/5 extensions to finite SOC, Γ/Γ', and DM physics require a different architecture.

The main failure mode is not in the physics but in the **engineering coherence between the
symbolic abstraction layer and the numerical state evaluation layer**. These two layers speak
different languages, and their interface is never formally closed.

The most urgent priorities are:
1. Fix the precompilation failure so tests can actually run.
2. Validate the physical basis states (Kramers doublets + d4 multiplets).
3. Implement the two empty physical oracle test files.
4. Fix the operator pipeline so SW output can be evaluated by the state evaluator.

After those four repairs, the project will have a clear, empirically grounded picture of whether
the numerical output is physically correct — which is the prerequisite for all further scientific work.
