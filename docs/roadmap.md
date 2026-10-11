# KitaevDerivation.jl: Master Pipeline & Roadmap

This document serves as the living calendar and structural roadmap for the development of the `KitaevDerivation.jl` framework. It must be updated as phases are successfully completed.

## 🟢 Phase 1: Foundational Algebra
**Status:** 100% SUCCESS

* **Scope:** Canonical Anticommutation Relations (CAR), normal ordering, abstract projector algebra, and the core `SymbolicUtils` rewriting engine.
* **`src/` Files:**
  * `src/BasisAndAlgebra.jl`
  * `src/AuxiliaryOperators.jl`
* **`test/` Files:**
  * `test/test_algebra.jl`
* **`lean/` Files:** N/A

## 🟢 Phase 2: Core Physics Subsystems (Virtual States & SOC)
**Status:** 100% SUCCESS *(strong-SOC limit; see architectural note below)*

* **Scope:** Single-site spin-orbit coupling ($j_{\text{eff}}=1/2$ and $3/2$ gaps) and two-site intermediate $d^4$ Kanamori multiplet analytical projection.
* **Architectural Note:** Phase 2A implements the **strong-SOC limit** ($\lambda \to \infty$),
  projecting directly onto the $j_{\text{eff}}=1/2$ Kramers doublet with fixed analytical coefficients.
  The $\lambda_{\text{SOC}} \to 0$ limit oracle is **architecturally excluded** by this design choice.
  Extending to finite $\lambda_{\text{SOC}}$ (required for $\Gamma$, $\Gamma'$, DM physics) requires
  a new basis implementation working with the full $6 \times 6$ single-site Hilbert space.
* **`src/` Files:**
  * `src/SingleSiteSOC.jl`
  * `src/TwoSiteKanamori.jl`
* **`test/` Files:**
  * `test/test_soc.jl`
  * `test/test_kanamori.jl` *(includes d4 basis orthonormality and Kramers doublet sign crosschecks)*
* **`lean/` Files:** N/A

## 🔴 Phase 3: Perturbation Engine & Exchange Extraction
**Status:** 30% SUCCESS (Critical interface defect diagnosed — repair in progress)

* **Scope:** The two-site Schrieffer-Wolff expansion ($H_{\text{eff}} = \mathcal{P} H_t \mathcal{R} H_t \mathcal{P}$) and isolating the Jackeli-Khaliullin constants ($J, K$) via Pauli trace identities.
* **Known Defects (from `docs/critical_review_2026.md`):**
  1. `SchriefferWolff.jl` ↔ `ExchangeExtraction.jl` interface mismatch: `MultipletProjector` is applied to d5 (1-hole) states, not d4 (2-hole) states.
  2. `P_low` projection flanking missing in `compute_effective_hamiltonian`.
  3. `lambda_soc` parameter in `project_to_pseudospin` is phantom (strong-SOC architectural limit).
* **`src/` Files:**
  * `src/KineticHopping.jl`
  * `src/SchriefferWolff.jl`
  * `src/ExchangeExtraction.jl`
* **`test/` Files:**
  * `test/test_kinetic_hopping.jl`
  * `test/test_schrieffer_wolff.jl`
  * `test/test_exchange.jl`
  * `test/test_pauli_trace.jl`
  * `test/test_point_group.jl`
  * `test/test_cancellation.jl` *(newly implemented: [PHYSICAL_ORACLE] J_H=0 ⟹ J=K=0)*
  * `test/test_symmetries.jl` *(newly implemented: [SYMMETRY] C2: J_xx=J_yy on z-bond)*
* **`lean/` Files:** N/A

## ⚪ Phase 4: Three-Site Interactions
**Status:** 0% SUCCESS (Pending)

* **Scope:** Extending the perturbation engine to 3-site hopping paths (e.g., $i \to j \to k$). This extracts third-order and relevant ring-exchange interactions. *(Note: 4-site terms are strictly excluded from the scope of this framework).*
* **`src/` Files:**
  * `src/ThreeSiteExchange.jl` (To be created)
* **`test/` Files:**
  * `test/test_three_site.jl` (To be created)
* **`lean/` Files:** N/A

## ⚪ Phase 5: Extensions (Distortions & Symmetry Breaking)
**Status:** 0% SUCCESS (Pending)

* **Scope:** Introducing trigonal distortions (direct hopping $t_1, t_3$) to compute symmetric off-diagonal exchange ($\Gamma, \Gamma'$), and local potentials ($V_0$) to generate antisymmetric Dzyaloshinskii-Moriya (DM) exchange.
* **`src/` Files:**
  * Modifies `src/KineticHopping.jl` and `src/ExchangeExtraction.jl`
* **`test/` Files:**
  * `test/test_symmetries.jl`
  * `test/test_intertwining.jl`
  * `test/test_appendix_a.jl`
* **`lean/` Files:** N/A

## ⚪ Phase 6: Formal Verification (Lean 4)
**Status:** 0% SUCCESS (Pending)

* **Scope:** Translating the symbolic AST derivation traces produced by Julia into machine-checkable Lean 4 theorems. This guarantees the ring algebraic equivalence of the final effective Hamiltonian.
* **`src/` Files:** N/A
* **`test/` Files:** N/A
* **`lean/` Files:**
  * `lean/Main.lean`
  * `lean/Algebra.lean`
  * `lean/Projectors.lean`

## 🔄 Phase 7 (Continuous): End-User Software & Documentation
**Status:** ONGOING (Developed in tandem)

* **Scope:** Building the public API to allow human theoretical physicists to interact with the framework. The user provides bond geometries and parameters, and the package yields the *symbolic* (not necessarily numeric) effective Hamiltonian. Developed concurrently via continuous docstrings, inline comments, and Julia `Documenter.jl` setup.
* **`src/` Files:**
  * `src/KitaevDerivation.jl` (Top-level API exports)
* **`test/` Files:**
  * `test/runtests.jl` (API integration tests)
* **Documentation Files:**
  * `docs/make.jl` (Documenter build script)
  * `docs/src/index.md`
