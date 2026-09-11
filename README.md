# Kitaev Derivation: Automated Formalization of the Extended Kitaev-Heisenberg Model

This repository contains a mathematically rigorous neuro-symbolic framework (Julia + Lean 4) designed to derive the low-energy effective spin Hamiltonian of strongly correlated $4d/5d$ Mott insulators.

## Project Scope
The framework transcribes the exact Hubbard-Kanamori algebraic derivations (such as the Jackeli-Khaliullin mechanism) into a Computer Algebra System (CAS) pipeline. It explicitly prevents combinatorial explosion (expression swell) by utilizing analytical state-projection, idempotent projectors, and sequential right-to-left canonical anti-commutation relations (CAR) instead of dense 15x15 matrix diagonalizations or unrestrained operator expansions.

### Core Physical Approximations
1. **$10Dq \to \infty$**: Isolates the $t_{2g}$ manifold.
2. **$U \sim J_H \gg \lambda_{\text{SOC}} \gg t_{ij}$**: Defines the strong-coupling basis. We mathematically project directly onto the strong Spin-Orbit Coupling limit ($j_{eff} = 1/2$), treating $\lambda \to \infty$ as the unperturbed ground-state manifold.

## Architecture Pipeline
- **`BasisAndAlgebra.jl`** - Symbolic fermionic algebra, CAR, and non-commutative operator AST structures.
- **`SingleSiteSOC.jl`** - Spin-Orbit Coupling and analytical projection onto the strong SOC limit ($j_{eff} = 1/2$).
- **`TwoSiteKanamori.jl`** - Analytical eigenvalues and projectors for $d^4$ intermediate angular momentum states ($L=0, 1, 2$).
- **`KineticHopping.jl`** - Physical hopping operators ($T_1, T_{-1}$) mapping arbitrary bond geometries based on Slater-Koster transfer matrices.
- **`SchriefferWolff.jl`** - Exact construction of the effective scattering operator strings ($T_{-1} \mathcal{R} T_1$) preserving strict operator ordering.
- **`ExchangeExtraction.jl`** - The state evaluator. Constructs exact multi-orbital Kramers doublets, evaluates the non-commutative fermionic strings mathematically right-to-left to track exact phase overlaps, and extracts the effective $J, K, \Gamma, \Gamma'$ coefficients.

## Documentation
For a complete snapshot of the codebase design, physical justifications, and why dense symbolic diagonalization is avoided, see [docs/software_snapshot.md](docs/software_snapshot.md).

## Verification
All mathematical derivations are bound by strict Test-Driven Development (TDD) Oracles in `/test`, ensuring the CAS preserves physical invariants (e.g., exact point-group symmetries, non-zero effective coupling bounds, and exact cancellation identities).
