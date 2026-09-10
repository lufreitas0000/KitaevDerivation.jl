# Kitaev Derivation: Automated Formalization of the Extended Kitaev-Heisenberg Model

This repository contains the neuro-symbolic framework (Julia + Lean 4) designed to derive the low-energy effective spin Hamiltonian of strongly correlated $4d/5d$ Mott insulators.

## Project Scope
The framework transcribes the exact Hubbard-Kanamori algebraic derivations (Jackeli-Khaliullin mechanism) into a rigorous Computer Algebra System (CAS) pipeline. It explicitly prevents combinatorial explosion by utilizing idempotent projectors and canonical anti-commutation relations (CAR) instead of dense matrix instantiations.

### Core Physical Approximations
1. **$10Dq \to \infty$**: Isolates the $t_{2g}$ manifold.
2. **$U \sim J_H \gg \lambda_{\text{SOC}} \gg t_{ij}$**: Defines the strong-coupling basis and mandates that the intermediate two-hole $d^4$ states are block-diagonalized strictly prior to SOC evaluation.

## Architecture Pipeline
- **Module 1: `BasisAndAlgebra.jl`** - Symbolic fermionic algebra, CAR, and non-commutative normal-ordering (Wick contractions).
- **Module 2: `SingleSiteSOC.jl`** - Spin-Orbit Coupling and $T-P$ equivalence mappings.
- **Module 3: `TwoSiteKanamori.jl`** - Analytical eigenvalues and projectors for $d^4$ intermediate states.
- **Module 4: `SchriefferWolff.jl`** - Recursive Lie-algebraic solver for canonical transformations.
- **Module 5: `ExchangeExtraction.jl`** - Pauli trace identities for $J, K, \Gamma, \Gamma'$ tensor isolation.

## Verification
All mathematical derivations are bound by Test-Driven Development (TDD) Oracles in `/test`, ensuring the CAS preserves physical invariants (e.g., Jackeli-Khaliullin cancellation, parity under bond inversion).
