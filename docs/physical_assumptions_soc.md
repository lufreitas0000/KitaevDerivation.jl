# Physical Assumptions: Spin-Orbit Coupling and Projection

In the derivation of the Extended Kitaev-Heisenberg Model, the treatment of the Spin-Orbit Coupling (SOC) is one of the defining architectural choices. This document details our physical assumptions, the reason for our "hard approximation" projection, and the limitations of this approach.

## 1. The Strong SOC Limit Assumption

We strictly enforce the energy scale hierarchy:
$$ 10Dq \gg U \sim J_H \gg \lambda_{SOC} \gg t_{ij} $$

Under this hierarchy:
1. $10Dq \to \infty$ isolates the $t_{2g}$ orbitals.
2. The Coulomb and Hund interactions $U, J_H$ entirely determine the virtual intermediate states during superexchange ($d^4$ multiplets).
3. Because $\lambda_{SOC} \gg t_{ij}$, the atomic ground state is split into a lower $j_{eff} = 1/2$ Kramers doublet and an excited $j_{eff} = 3/2$ quartet, separated by a gap $\Delta E_{SOC} = \frac{3\lambda}{2}$. The kinetic hopping $t_{ij}$ is considered a weak perturbation on this strongly split ground state manifold.

## 2. The Hard Projection Approximation

Instead of diagonalizing the $6^N$-dimensional single-site Hilbert space with both hopping and SOC active concurrently, we perform a **hard analytical projection** at the end of the kinetic expansion:
$$ H_{eff} = \mathcal{P}_{1/2} H_t \mathcal{R} H_t \mathcal{P}_{1/2} $$
where $\mathcal{P}_{1/2}$ represents the projection onto the $j_{eff} = 1/2$ states. 

**Why we chose this:**
- **Combinatorial Control:** Projecting directly onto the $j_{eff}=1/2$ basis immediately prunes the local state space from 6 degrees of freedom (3 orbitals $\times$ 2 spins) down to 2 effective spin states. Without this, expanding the Schrieffer-Wolff perturbation over the unconstrained fermionic operators would result in an intractable combinatorial explosion within the CAS.
- **Physical Consistency:** As long as $\lambda_{SOC} \gg t_{ij}$, the virtual admixture of $j_{eff}=3/2$ states into the ground state by kinetic hopping is suppressed by $\mathcal{O}(t / \lambda)$.

## 3. What Could Be Done Differently

A more comprehensive approach would relax the strict inequality $\lambda_{SOC} \gg t_{ij}$ and treat SOC and hopping competitively. 

**Alternative:** "Full $t_{2g}$ Perturbation Theory"
- One could compute the full intermediate $t_{2g}$ exchange Hamiltonian *without* projecting. 
- The $j_{eff} = 3/2$ states would be explicitly retained as active virtual pathways in the resolvent expansion.

## 4. Limitations and Impact on End Results

By projecting rigidly onto the $j_{eff} = 1/2$ doublet:
1. **Missing Third-Order Corrections:** We lose virtual excitation paths like $j_{eff}=1/2 \to 3/2 \to 1/2$. In highly distorted materials (like some Iridates or Ruthenates) where $\lambda \sim t$, these pathways generate significant pseudo-dipolar and Dzyaloshinskii-Moriya (DM) interactions.
2. **Trigonal Distortions:** If a trigonal crystal field $\Delta_{trig}$ is present and comparable to $\lambda$, the $j_{eff}$ basis itself mixes. A hard projection inherently assumes $\Delta_{trig} \ll \lambda$. 
3. **The Non-Relativistic Limit Test:** Because $\lambda_{SOC} \to \infty$ is baked into the basis choice ($\mathcal{P}_{1/2}$), taking the continuous mathematical limit $\lambda_{SOC} \to 0$ after projection is mathematically ill-posed. The Kitaev exchange $K$ relies on this projection, and evaluating it directly at $\lambda=0$ requires reverting to the raw orbital basis.
