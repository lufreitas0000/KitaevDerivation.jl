# KitaevDerivation.jl: Architecture and Implementation Snapshot

## 1. Overview
`KitaevDerivation.jl` is a rigorous mathematical-physics framework designed to derive the effective Kitaev/Heisenberg interactions from a microscopic multi-orbital Hubbard-Kanamori Hamiltonian. The codebase leverages symbolic algebra (via `Symbolics.jl` and `SymbolicUtils.jl`) to correctly execute a symbolic Schrieffer-Wolff expansion up to arbitrary order. 

The primary scientific requirement of this framework is to prevent explosive computational complexity ("expression swell") by enforcing strict non-commutative algebraic ordering and sequential right-to-left state projections, rather than relying on dense matrix eigensolvers or blind operator string expansions.

## 2. Directory Structure and Modules

### `src/` (Core Logic)
- **`BasisAndAlgebra.jl`**: The foundation of the CAS. It defines the AST structure for non-commutative quantum operators (`FermionC`, `FermionA`, `SpinComposite`, `OperatorString`, etc.), canonical anticommutation relations (CAR), Wick contraction primitives, and the `evaluate_pauli_trace` engine.
- **`SingleSiteSOC.jl`**: Implements the single-site spin-orbit coupling (SOC) Hamiltonian and defines the projection analytically onto the strong SOC limit ($j_{eff} = 1/2$).
- **`TwoSiteKanamori.jl`**: Defines the physical multiplet projectors ($L=0, 1, 2$) and resolvent rules based on the analytical Kanamori eigen-energies for the intermediate $d^4$ two-hole states.
- **`KineticHopping.jl`**: Encodes the Slater-Koster transfer matrices and physical hopping processes ($T_1, T_{-1}$) for arbitrary bond geometries.
- **`SchriefferWolff.jl`**: Handles the symbolic construction of the effective operator strings ($T_{-1} \mathcal{R} T_{1}$) while strictly preserving their ordering to prevent projector-bypassing bugs.
- **`ExchangeExtraction.jl`**: The projection state-evaluator. Natively constructs the exact Kramers doublets and multi-orbital $d^4$ basis, applies the fermionic strings mathematically right-to-left, and extracts the effective $J, K, \Gamma, \Gamma'$ coefficients by projecting onto Pauli matrices.
- **`AuxiliaryOperators.jl`**: Helper definitions to isolate different operator sectors.

### `test/` (Test Suite & Oracles)
- **`test_algebra.jl`, `test_pauli_trace.jl`**: Validates the non-commutative algebraic logic and Pauli trace derivations.
- **`test_soc.jl`, `test_kanamori.jl`, `test_kinetic_hopping.jl`**: Verifies the site-local models, eigenvalues, and transfer matrices.
- **`test_schrieffer_wolff.jl`, `test_exchange.jl`**: The integration tests. Ensures that the full physical output respects required limit oracles and symmetry constraints without hardcoding results.

---

## 3. Physical Justifications and Algorithmic Design

### A. Why Analytical Projection instead of Dense Diagonalization?
The two-hole $d^4$ virtual intermediate manifold contains 15 non-trivial states. Generating and symbolically diagonalizing a dense $15 \times 15$ symbolic matrix is computationally prohibitive—it leads to massive intermediate expression swell, unreadable determinants, and obscures the distinct physical scattering channels.

Instead, we employ **analytical projection**:
1. We decompose the intermediate space exactly into orthogonal angular momentum multiplet projectors ($P_{L=0}, P_{L=1}, P_{L=2}$).
2. We assign them analytical Kanamori resolvent eigen-energies ($\Delta E_L$).
3. We preserve operator ordering rigorously and execute state-evaluation sequentially from right-to-left.

This method keeps symbolic growth highly linear and scalable, enabling us to move to 3-site (3rd order) perturbations easily without encountering memory limits.

### B. The Non-Relativistic Limit Test ($\lambda_{SOC} \to 0$)
Previously, a mathematical oracle was employed stating that at $\lambda_{SOC} \to 0$, the anisotropic Kitaev exchange $K \to 0$. 
**Why this test is conceptually ill-posed in the current architecture:**
Our framework mathematically projects the effective Hamiltonian directly onto the **strong Spin-Orbit Coupling limit** ($j_{eff} = 1/2$ Kramers doublet states). These basis states inherently assume $\lambda_{SOC} \to \infty$. 

Because we project onto these states analytically to prevent dense $6 \times 6$ expansion, the $\lambda_{SOC}$ variable is absorbed into the basis definition and does not appear freely in the extracted Hamiltonian. Attempting to take the $\lambda_{SOC} \to 0$ limit *after* projection into the infinite-$\lambda_{SOC}$ manifold is a mathematical contradiction.

As such, we do not test for the continuous non-relativistic limit. Instead, our testing philosophy is to mandate mathematically independent "Non-Zero Oracles" and point-group symmetry constraints (e.g. $C_2$ and $C_3$) directly on the extracted analytical tensors at the strong-SOC limit.
