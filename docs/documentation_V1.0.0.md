# Kitaev-Heisenberg Formal Derivation: Architectural Blueprint V1.0.0

## 1. Structural Vulnerabilities and Mathematical Approaches

### I. Resolving the AST Translation Gap (Julia to Lean 4)
The absence of a native bridge between Julia's Computer Algebra System (CAS) and Lean 4's dependent type theory requires a strictly defined Intermediate Representation (IR).

*   **Approach A: S-Expression Export to `Lean.Expr`**
    Develop a serialization module within Julia that intercepts the final simplified AST from `Symbolics.jl` or `QuantumAlgebra.jl`. This module must recursively map Julia's expression tree into Lisp-like S-expressions (e.g., `(Add (Mul J (Dot S_i S_j)) (Mul K (Dot S_i S_k)))`). Lean 4 possesses native metaprogramming capabilities capable of parsing S-expressions directly into `Lean.Expr` objects for theorem validation.
*   **Approach B: Certificate-Based Verification (Decoupled Logic)**
    Do not attempt to translate the entire computational trace. Shift the verification paradigm: use Lean 4 exclusively to formalize and prove the fundamental algebraic rewriting rules (e.g., proving the $T-P$ equivalence or the projector orthogonality). Julia then uses these verified rules as axioms. The framework generates a "Proof Certificate" in Julia (a log of which Lean-verified rules were applied), bypassing the need to translate the raw mathematical state between languages.

### II. Resolving Projector Algebra Constraints
`QuantumAlgebra.jl` reduces operators to fundamental constituents. Expanding projectors into Pauli matrices prematurely will trigger the combinatorial explosion the projections are designed to prevent.

*   **Approach A: Custom Non-Commutative Algebraic Rules**
    Define $P_{\text{singlet}}$ and $P_{\text{triplet}}$ as opaque, non-commutative symbolic variables. Utilize `SymbolicUtils.jl` to define a custom rule set that intercepts the multiplication chain before `QuantumAlgebra.jl` evaluates it. Constraints such as $P_{\text{singlet}} \cdot P_{\text{triplet}} = 0$ and $P_{\text{singlet}} + P_{\text{triplet}} = 1$ must be enforced dynamically during expansion.
*   **Approach B: Lazy Operator Mapping**
    Maintain the projectors as abstract scalar variables throughout the Two-Site Multiplets and Schrieffer-Wolff modules. Execute the mapping $P_{\text{singlet}} \mapsto \frac{1}{4} - \bm{S}_i \cdot \bm{S}_j$ only at the point where projection onto the Pauli tensor basis is strictly required.

### III. Resolving Combinatorial Explosion in Resolvent
Evaluating the full operator sequence $\mathcal{P}_0 H_t \mathcal{R} H_t \mathcal{P}_0$ unconditionally will exhaust RAM, as intermediate tensor products scale exponentially across the 15-dimensional $d^4$ manifold.

*   **Approach A: Right-to-Left Sequential State Action**
    Abandon explicit matrix multiplication. Treat operators as actions on a defined symbolic state vector $\vert\phi_0\rangle = \mathcal{P}_0$. Compute sequential transitions ($\vert\psi_1\rangle = H_t \vert\phi_0\rangle$, $\vert\psi_2\rangle = \mathcal{R} \vert\psi_1\rangle$), applying simplification rules and pruning zero-terms at each discrete step.
*   **Approach B: Symmetry-Sector Pre-Filtering**
    Before executing the symbolic expansion in Julia, construct a lightweight numerical filter that tracks Abelian conserved quantum numbers (e.g., $J_z$). Map the $15 \times 15$ intermediate space as a sparse adjacency graph. If a sequence of hopping operators violates the selection rules connecting the $j_{\text{eff}} = 1/2$ ground state to a specific intermediate Kanamori multiplet, the corresponding symbolic AST node is preemptively aborted.

---

## 2. Current Project State
The working environment `KitaevDerivation.jl` is initialized. Dual version control (Git + DVC) is active. The directory architecture mirrors the modular constraints specified in the computational blueprint. Empty files exist for the TDD test suite, the Julia source modules, and the Lean 4 formalization scripts.

## 3. Proposed Next Steps
1.  **Define Signatures:** Draft the explicit Julia abstract types and function signatures for `BasisAndAlgebra.jl`.
2.  **Establish Oracles:** Write the failing TDD unit tests in `test_algebra.jl` encoding the Canonical Anti-commutation Relations (CAR) and the non-commutative algebraic invariants $P_{\text{singlet}} + P_{\text{triplet}} = I$ and $P_{\text{singlet}} \cdot P_{\text{triplet}} = 0$.
3.  **Module Implementation:** Construct the core logic for `BasisAndAlgebra.jl` strictly constrained by the defined Oracles.

---

## 4. Initialization Commit Record
**Message:** `build: initialize project architecture and dependency scaffolding`
**Details:**
* Establish directory structure (src, test, lean, data, docs).
* Define Julia Project.toml with Symbolics.jl and QuantumAlgebra.jl.
* Instantiate Lean 4 toolchain (v4.33.1) and Lakefile.
* Initialize Git and DVC version control environments.



## 5. Integration with Google Antigravity agent AGY on VS code WSL Ubuntu

Git tracks source code, configuration, experiments, and DVC metadata. DVC tracks large data/artifacts. Never commit DVC-managed data files to Git.

### Using DVC with an Agentic Coding Workflow

Integrating Data Version Control (DVC) alongside Git and GitHub within an agentic coding system requires a clear division of labor: **Git tracks source code, configurations, and DVC metadata**, while **DVC tracks large data, models, and experiment artifacts** (stored in a remote destination like Google Drive).

For an autonomous coding agent to operate safely and predictably, it must distinguish between different types of changes and apply the corresponding workflow:

* **Code-only changes:** When modifying source code, notebooks, configurations, or tests, standard Git operations are sufficient (`git add .`, `git commit -m "..."`, `git push`). No DVC commands are required.
* **Data-only changes:** If a DVC-tracked file is modified, update its content hash and metadata by running `dvc add <file>`, commit the resulting `.dvc` file to Git, push the metadata to GitHub via `git push`, and finally upload the actual data object to the remote storage using `dvc push`.
* **Combined code and data changes:** For projects where both analysis logic and results change simultaneously, update the DVC metadata first (`dvc add <changed-data>`), commit the complete project state via Git (`git add .`, `git commit`, `git push`), and conclude by pushing the actual data (`dvc push`). This establishes a reproducible link where a specific Git commit points to an exact `.dvc` hash.
* **Retrieving project states:** When cloning or switching to a repository on another machine or agent, Git provides the source code and metadata, but the heavy data files remain local-only until retrieved using `dvc pull` right after a `git pull`.

**Core Rules for Autonomous Coding Agents**

* **Code in Git, Data in DVC:** Source code, notebooks, tests, documentation, and `.dvc` metadata belong in Git. Raw large datasets must stay out of Git and be managed entirely via `dvc add` and `dvc push`.
* **Explicit retrieval:** Always follow repository updates with `dvc pull` to synchronize heavy data assets.
* **Prohibit destructive commands:** Agents must never run `dvc gc` (garbage collection) automatically, as it can permanently purge cached or remote objects.
* **Protect authentication:** Never modify, commit, or expose local configuration files (`.dvc/config.local`) or GDrive client secret credentials to Git.
