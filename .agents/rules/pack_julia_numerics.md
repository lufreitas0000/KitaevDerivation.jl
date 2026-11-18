<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Pack: Julia Quantitative Metrology & Symbolic Physics

This pack governs high-performance numerical physics (matrix-free Krylov, ED solvers, Arnoldi/Lanczos iterations) and symbolic CAR/Lie algebra derivations implemented in Julia.

---

## 1. Matrix Conditioning, Krylov Invariants & Residual Tolerances

1. **Matrix Conditioning & Solver Residuals:**
   - For linear systems and generalized eigenproblems, monitor conditioning $\kappa(\mathbf{A})$. For Krylov eigensolvers (`KrylovKit.jl`, `ArnoldiMethod.jl`), verify true operator residual $\| \mathbf{H} \psi - E \psi \|_2 / |E| < \epsilon_{\mathrm{tol}}$ rather than relying solely on Ritz estimate tolerances.
2. **Spectral & Gauge Symmetries:**
   - Enforce exact preservation of algebraic symmetries:
     - Particle-hole anti-unitary symmetry: $\{\mathbf{H}, \mathcal{C}\} = 0$.
     - Time-reversal symmetry: $[\mathbf{H}, \mathcal{T}] = 0$.
     - Fermionic CAR anti-commutation relations: $\{c_i, c_j^\dagger\} = \delta_{ij} \mathbf{I}$.
   - Flag any gauge or algebraic drift exceeding machine precision ($> 10^{-13}$ in double precision).

---

## 2. Metrology, Bayesian Model Comparison & FSS

1. **Statistical Ensembles & Bootstrap:**
   - Sample $N_{\mathrm{samples}} \ge 50$ for disordered or stochastic runs.
   - Report non-parametric bootstrap 95% confidence intervals ($B \ge 1,000$ resamples) for critical couplings and excitation gaps.
2. **Bayesian Model Selection ($\Delta\mathrm{BIC}$ / $\Delta\mathrm{AICc}$):**
   - In scaling regressions (e.g. finite-size gap scaling $\Delta(L) \sim L^{-z}$ vs. exponential $\Delta(L) \sim e^{-L/\xi}$), evaluate competing models via $\Delta\mathrm{BIC}_{01} = \mathrm{BIC}(\mathcal{M}_0) - \mathrm{BIC}(\mathcal{M}_1)$.
   - Require $\Delta\mathrm{BIC}_{01} > 10$ with small-sample $\mathrm{AICc}$ verification and autocorrelation correction $n_{\mathrm{eff}}$.
3. **Finite-Size Scaling Two-Sided Holdout:**
   - Perform leave-$L_{\min}$-out (sub-asymptotic boundary check) and leave-$L_{\max}$-out (extrapolation stability check) on all thermodynamic limit projections.
