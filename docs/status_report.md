# KitaevDerivation.jl Status Report

## Current Status
The `KitaevDerivation.jl` repository implements a symbolic computation framework in Julia to derive an effective Kitaev/Heisenberg Hamiltonian from a microscopic Hubbard-Kanamori model.

The codebase is currently in Phase 3 of its development graph (according to `AGENTS.md` and `DELEGATION_PROMPTS.md`), with the following modules active and successfully passing their mathematically-verified tests:
1. **Phase 1: `BasisAndAlgebra.jl`** - Basic non-commutative symbolic fermionic algebra and canonical anti-commutation relations.
2. **Phase 2A: `SingleSiteSOC.jl`** - Single-site Spin-Orbit Coupling approximations.
3. **Phase 2B: `TwoSiteKanamori.jl`** - Exact exact multiplet projection for intermediate $d^4$ states.
4. **Phase 3: `SchriefferWolff.jl` & `ExchangeExtraction.jl`** - Constrained second-order perturbation using analytical resolvent channels and tensor isolation.

All 244 exact and oracle-driven algebraic/physical tests are currently **PASSING**. The complexity boundaries and exact limits (e.g., Jackeli-Khaliullin cancellation at $J_H=0$) are strictly maintained.

## Next Steps
The next step is to advance to **Phase 4**, which comprises:
1. Validating the generated symbolic rewrite certificates using **Lean 4**.
2. Incorporating physical variations:
   * **Bond Distortions:** Modifying the canonical symmetry assumptions for real-world material parameters.
   * **Gamma / Gamma' terms:** Ensuring generalized off-diagonal exchange tensors remain mathematically consistent.
   * **Dzyaloshinskii-Moriya (DM) interactions:** Extending the perturbation engine for anti-symmetric exchange.
   * **Local Potentials.**

## Execution Protocol Acknowledgement
When tasked with implementing these features, I will assume the designated operational roles (`physics-implementer`, `test-generator`, `execution-worker`) and strictly follow the TDD Cycle: first defining the mathematical oracle in `test/`, validating its initial failure, and subsequently implementing the minimal necessary transformations in `src/` inside the defined safe CAS boundaries.
