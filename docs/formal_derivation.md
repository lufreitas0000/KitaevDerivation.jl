# Formal Derivation of the Extended Kitaev-Heisenberg Model

## 1. Physical Context and Core Approximations
- We enforce a strict hierarchy of energy scales: $10Dq \gg U \sim U', J_H \gg \lambda_{\text{SOC}} \gg t_{ij}$.
- The $10Dq \to \infty$ approximation splits the $d$-orbitals into a lower $t_{2g}$ and higher $e_g$ manifold.
- We project out the $e_g$ states to prevent combinatorial explosion.
- A hole hopping from site $i$ to site $j$ creates a two-hole $d^4$ virtual intermediate state on site $i$.
- The dimensionality of this virtual intermediate state is 15 states ($\binom{6}{2}$).
- The resolvent operator $(E_0 - H_0)^{-1}$ acts entirely on this 15-dimensional $d^4$ manifold.

## 2. Extensions Beyond the Pure Kitaev Model
- Trigonal distortions generate non-Kitaev symmetric off-diagonal exchange terms: $H_{\Gamma} = \Gamma (S_i^\alpha S_j^\beta + S_i^\beta S_j^\alpha)$.
- Local electrical potentials $V_0$ break the inversion symmetry center at the bond midpoint.
- The resolvent energies break their denominator symmetry: $\Delta E_L \longrightarrow \Delta E_L \pm eV_0$.
- This symmetry breaking generates the Dzyaloshinskii-Moriya (DM) interaction.

## 3. Computational Blueprint
- Diagonalizing $15 \times 15$ matrices symbolically is algebraically explosive.
- We use analytical projection operators ($P_{\text{singlet}}$, $P_{\text{triplet}}$, $P_{L=0,1,2}$) instead of dense matrices.
- The $T-P$ equivalence maps the orbital angular momentum to an effective spin $\bm{L} = -\bm{l}_{\text{eff}}$.
- We construct the unitary mapping to project onto the $j_{\text{eff}}=1/2$ Kramers doublet directly.
- The Pauli trace identities factorize the resulting operator matrix into $J, K, \Gamma, \Gamma'$ and $D$.
- The Jackeli-Khaliullin Cancellation Oracle states that if $J_H = 0$, then $J=0, K=0, \Gamma=0$.
- The Point-Group Oracle states that under $C_2$ bond inversion, the extracted tensor maps symmetrically (e.g., $J_{xx} = J_{yy} \neq J_{zz}$ on a $z$-bond).

## 4. Hubbard-Kanamori Model
- The atomic Hamiltonian is given by:
  $$ V = \sum_i \left[ \frac{U-3J_H}{2}(N_i-5)^2 - 2J_H \bm{S}_i^2 - \frac{J_H}{2}\bm{L}_i^2 \right] $$
- The spin-orbit coupling is:
  $$ H_{so} = -\lambda \sum_i \bm{S}_i \cdot \bm{L}_i $$
- At low energies, the holes occupy the $j_{\text{eff}}=1/2$ Kramers doublets:
  $$ |+\rangle = \frac{1}{\sqrt{3}} (-|z, \uparrow\rangle - i|y, \downarrow\rangle - |x, \downarrow\rangle) $$
  $$ |-\rangle = \frac{1}{\sqrt{3}} (|z, \downarrow\rangle + i|y, \uparrow\rangle - |x, \uparrow\rangle) $$
- The orbital-dependent hopping Hamiltonian is partitioned into $T_0$, $T_1$, and $T_{-1}$.
- The commutators between the hopping operators and the atomic Hamiltonian shift the energy by the Kanamori eigenvalues:
  $$ \Delta E_0 = U + 2J_H, \quad \Delta E_1 = U - 3J_H, \quad \Delta E_2 = U - J_H $$
- The second-order effective Hamiltonian is given by:
  $$ \mathcal{P}_{\text{low}} \tilde{H} \mathcal{P}_{\text{low}} = -\frac{1}{2} \mathcal{P}_{\text{low}} (T_{-1} S_1^{(+)} + S_1^{(-)} T_1) \mathcal{P}_{\text{low}} $$
- Substituting the projection operators and summing over the $L=0, 1, 2$ channels yields the effective Heisenberg and Kitaev interactions:
  $$ H_{\text{eff}} = -\frac{8J_H t^2}{3(U-3J_H)(U-J_H)} \sum_{\langle ij \rangle_{\gamma}} S_i^{\gamma} S_j^{\gamma} $$

## 5. Appendix: Commutator Algebra
- The Coulomb repulsion $V_N$ commutes with the hopping operator $T_1$ to yield an energy shift:
  $$ [V_N, T_1] = (U-3J_H) T_1 $$
- The spin term $V_S$ commutes with the hopping operator to distinguish the singlet and triplet channels:
  $$ [V_S, T_1] = -J_H \sum_{ij} (3\mathcal{P}_{i, \text{sing}}^{(2)} - \mathcal{P}_{i, \text{trip}}^{(2)}) h_i^{\dagger} \tilde{T}_{ij} h_j \mathcal{P}_j^{(1)} $$
- The orbital term $V_L$ further splits the singlet channel into $L=0$ and $L=2$:
  $$ [V_L, T_1] = -J_H \sum_{ij} (2\mathcal{P}_{i, L=0}^{(2)} + \mathcal{P}_{i, L=1}^{(2)} - \mathcal{P}_{i, L=2}^{(2)}) h_i^{\dagger} \tilde{T}_{ij} h_j \mathcal{P}_j^{(1)} $$
