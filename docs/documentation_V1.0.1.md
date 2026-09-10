# Formal Derivation Architecture: Phase 2 Review and Phase 3 Blueprint

## 1. Physical Assumptions and Subspace Pruning (Phase 2)
The derivation of the Kitaev-Heisenberg effective Hamiltonian strictly depends on avoiding the diagonalization of the intermediate many-body states. The full state space of $d^4$ virtual states scales factorially; representing it via dense matrices exhausts CAS memory.

We enforce the physical hierarchy:
$$ 10Dq \gg U \sim J_H \gg \lambda_{\text{SOC}} \gg t_{ij} $$

### 1.1 Hubbard-Kanamori Eigenvalues (`TwoSiteKanamori.jl`)
Because $U \sim J_H \gg \lambda_{\text{SOC}}$, the resolvent operator $\mathcal{R} = (E_0 - H_0)^{-1}$ is evaluated strictly in the $L-S$ basis. We map the analytical Kanamori eigenvalues directly to abstract idempotent projectors:
- $\Delta E_0 = U + 2J_H \implies \mathcal{P}_{L=0}$
- $\Delta E_1 = U - 3J_H \implies \mathcal{P}_{L=1}$
- $\Delta E_2 = U - J_H \implies \mathcal{P}_{L=2}$

The action of the resolvent is defined via algebraic rewriting rules:
$$ \mathcal{R} \mathcal{P}_{L} = \frac{1}{\Delta E_L} \mathcal{P}_{L} $$
This operation circumvents explicit tensor contractions in the intermediate Hilbert space.

### 1.2 Spin-Orbit Coupling and T-P Equivalence (`SingleSiteSOC.jl`)
The $t_{2g}$ manifold maps to an effective angular momentum $l_{\text{eff}}=1$. We apply the strict $T-P$ equivalence:
$$ \mathbf{L}_{t_{2g}} \to -\mathbf{l}_{\text{eff}} $$

Given $\lambda_{\text{SOC}} \gg t_{ij}$, the ground state is isolated in the $j_{\text{eff}} = 1/2$ Kramers doublet. The algorithm bypasses $6 \times 6$ matrix multiplication by substituting the projection operator action algebraically:
$$ \mathcal{P}_{1/2} H_{\text{SOC}} \mathcal{P}_{1/2} = \frac{\lambda}{2} \mathcal{P}_{1/2} $$

## 2. Blueprint for Phase 3: Generalized Schrieffer-Wolff Engine
The objective of Phase 3 is to evaluate the canonical transformation recursively.

### 2.1 The Generator $S_n$
The transformation generator $S = S_1 + S_2 + \dots$ satisfies the Lie algebra constraints:
$$ [S_n, V] + \sum_{k=1}^{n-1} [S_k, T] + T^{(n)} = 0 $$

For the Hamiltonian expansion to $\mathcal{O}(t^2/U)$:
1. Solve $[S_1, V] = T_1 + T_{-1}$.
2. Evaluate $H_{\text{eff}}^{(2)} = -\frac{1}{2} \mathcal{P}_{1/2} (T_{-1} S_1^{(+)} + S_1^{(-)} T_1) \mathcal{P}_{1/2}$.

For the charge density expansion $\delta n_l$ to $\mathcal{O}(t^2 t'/U^3)$:
1. Solve $[S_2, V] + [S_1, T_0] = 0$.
2. Evaluate $\delta n_l = -\mathcal{P}_{1/2} S_2^{(-)} [n_l, S_1^{(+)}] \mathcal{P}_{1/2} + \text{h.c.}$

### 2.2 Trace Factorization (`ExchangeExtraction.jl`)
The resulting abstract polynomial will be projected onto Pauli matrices to extract the magnetic tensors $(J, K, \Gamma, \Gamma')$. The cas will apply the trace identities:
$$ \text{Tr}(\sigma^\alpha \sigma^\beta) = 2\delta^{\alpha\beta} $$
to isolate the coefficients algorithmically.
