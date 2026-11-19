# Research and engineering idea backlog — KitaevDerivation.jl

**Authority:** Non-committal local exploration queue (`IDEA-NNN`), distinct from `HORIZON.md` and `CURRENT_SPRINT.md`. Cross-project proposals live in [`/home/lucas/Projects/docs/NEXT_PROJECTS_INCUBATOR.md`](file:///home/lucas/Projects/docs/NEXT_PROJECTS_INCUBATOR.md).

## IDEA-001 — Port Appendix A macroscopic commutator TDD suite from archived `0aed437` bundle
Status: inbox
Question and motivation: Which assertions in `0aed437:test/test_appendix_a.jl` pass unchanged on `main` and which expose real missing sign factors in `ExchangeExtraction.jl`?
First inexpensive falsification or feasibility check: Inspect primary artifacts and write bounded test/check.

## IDEA-002 — Symmetry-reduced `ThreeSiteKanamori.jl` for third-order perturbation
Status: inbox
Source: CLI legacy transcripts [`3dd1ed1f-b205-43d5-b0da-9147d2432156`](conversation://3dd1ed1f-b205-43d5-b0da-9147d2432156) (Prompt 9) and [`3d892064-1c1d-447e-aa14-b475421e11c0`](conversation://3d892064-1c1d-447e-aa14-b475421e11c0).
Question and motivation: Can exploiting discrete $C_3$ bond/spin-orbital permutation symmetry ($x \to y \to z$) keep symbolic 3-site third-order Schrieffer–Wolff exchange extraction tractable for $\kappa$-type multi-spin couplings without blowing up `OperatorSum` term counts?
First inexpensive falsification or feasibility check: Benchmark exact $C_3$ orbit compression on a minimal 3-site $t_{2g}$ test cluster against full unreduced summation.

## IDEA-003 — Strong-SOC $j_{\mathrm{eff}}=1/2$ projection contract vs finite-SOC limit & anti-mock oracle audit
Status: inbox
Source: CLI legacy transcript [`3d892064-1c1d-447e-aa14-b475421e11c0`](conversation://3d892064-1c1d-447e-aa14-b475421e11c0) (Prompts 13, 21–23).
Question and motivation: Where does hard $j_{\mathrm{eff}}=1/2$ ground-manifold projection (`SingleSiteSOC.jl`) diverge from exact finite-$\lambda_{\mathrm{SO}}$ intermediate-state resolvents, and do all test files in `test/` avoid hardcoded oracle constants or circular assertions?
First inexpensive falsification or feasibility check: Add an automated finite-$\lambda_{\mathrm{SO}}$ limit convergence check ($\lambda_{\mathrm{SO}} \to \infty$) alongside a grep/AST check ensuring no mocked exchange tensors remain in `src/` or `test/`.
