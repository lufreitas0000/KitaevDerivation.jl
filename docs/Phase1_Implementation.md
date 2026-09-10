# Phase 1 Implementation Log: Basis and Algebra

## 1. Overview
The implementation of Phase 1 (`BasisAndAlgebra.jl`) establishes the symbolic and mathematical foundation for the formal Kitaev derivation. It structures the abstract algebraic representation of fermionic operators, projectors, and AST transformations strictly without reliance on dense matrix operations.

## 2. Operator Representations and AST Nodes
To maintain exact symbolic evaluations, the framework implements a specific Abstract Syntax Tree (AST) utilizing standard Julia types:
- **Fundamental Operators**: `FermionC` (creation, $c^\dagger$), `FermionA` (annihilation, $c$).
- **Algebraic Elements**: `IdentityOp` acts as the multiplicative neutral element, and `ZeroOp` acts as the absorbing element to safely prune non-existent channels.
- **Composite Types**: `ScaledOperator` (scalar coefficients), `OperatorString` (non-commutative products), and `OperatorSum` (linear combinations).
- **Subspace Projectors**: 
  - `MultipletProjector(L::Int, site::Symbol)`: Represents the two-hole $d^4$ intermediate states.
  - `LowEnergyProjector(jeff::String, site::Symbol)`: Represents the $j_{\text{eff}}$ ground-state doublet.

## 3. The Algebraic Engine
### A. Canonical Anticommutation Relations (CAR)
The `anticommutator` function evaluates exact symbolic pairs:
- Resolves spatial/orbital/spin modes returning `IdentityOp` for direct conjugates and `ZeroOp` for orthogonal states.
- Applies strict symbolic bilinearity for `ScaledOperator`, isolating symbolic numerical factors (e.g., $\{\alpha A, \beta B\} = \alpha\beta\{A, B\}$) without expanding redundant AST branches.

### B. Normal Ordering and Wick Contractions
The `sort_normal_order` engine orchestrates non-commutative multiplication:
- Iteratively applies lexicographical sorting for sequences of creation/annihilation operators.
- Extracts scalar multipliers (like $-1$) to enforce fermionic parity during operator exchange.
- Employs exact Wick contraction rules ($c c^\dagger = 1 - c^\dagger c$) and eagerly terminates nilpotency ($c c = 0$).

### C. Strict Hilbert Space Orthogonality
The `evaluate_projector_product` and `apply_algebraic_rules` routines manage subspace intersections:
- Validates cross-site commutation, allowing independent operations on sites $i$ and $j$ to form an `OperatorString`.
- Enforces mutual exclusivity on localized sites: products of physically orthogonal representations (like $d^4$ `MultipletProjector` and $d^5$ `LowEnergyProjector`) instantly collapse to `ZeroOp()`.

### D. Hermiticity and Symmetries
The `dagger` function strictly enforces Hermitian conjugation. Critically, it applies `conj()` to any symbolic numerical coefficient within a `ScaledOperator`. This structurally preserves imaginary phase gauges essential for resolving kinetic exchange tensors influenced by Spin-Orbit Coupling.

## 4. Phase Boundary Coordination
To ensure compatibility with upcoming algebraic steps, the `TwoSiteKanamori.jl` component (Phase 2B) and associated tests were patched. Kanamori extraction functions like `kanamori_eigenvalues` and `d4_multiplet_projectors` now accept and transmit `site::Symbol` parameters to perfectly inherit the Phase 1 representation without instigating compilation mismatches.
