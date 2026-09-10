### Critical Architectural Audit for `KitaevDerivation.jl`

Developing a neuro-symbolic framework for the Extended Kitaev-Heisenberg Hamiltonian requires moving past standard software Test-Driven Development (TDD). In computational physics, standard unit tests only verify syntactic validity; mathematical physics TDD must enforce physical invariants and algebraic boundaries before any code generation occurs.



Attempting to run an unconstrained LLM agent on this derivation will fail due to two primary mathematical and architectural bottlenecks:



1. **Abel-Ruffini Limitation and Matrix Diagonalization:** The intermediate two-hole $d^4$ virtual manifold contains $\binom{6}{2} = 15$ states. Instructing an agent to symbolically construct and diagonalize dense $15 \times 15$ matrices in Julia leads to algorithmic non-termination and algebraic hanging. The subagents must be explicitly restricted to abstract idempotent projector rewriting rules ($P_{L=0}, P_{L=1}, P_{L=2}$) with analytical Kanamori eigenvalues ($\Delta E_0 = U+2J_H$, $\Delta E_1 = U-3J_H$, $\Delta E_2 = U-J_H$).



2. **Combinatorial Explosion of the Resolvent:** Expanding the Schrieffer-Wolff perturbation $\mathcal{P}_0 H_t \mathcal{R} H_t \mathcal{P}_0$ across unconstrained fermionic operators generates thousands of intermediate tensor products that exhaust RAM and context windows. Subagents must apply right-to-left sequential state action, normal-ordering, and immediate projection into the $j_{\text{eff}} = 1/2$ Kramers doublet.




### AGY Subagent Topology & Model Allocation

Google Antigravity (AGY) should be structured as an asynchronous swarm with model specialization matched to latency, reasoning depth, and operational permissions:



|**Role**|**Target Model**|**Scope & Tool Permissions**|**Context Boundary**|
|---|---|---|---|
|**Architect / Main Agent**|High-Capacity Reasoning (e.g., Gemini Pro)|Coordinates modules, verifies invariant preservation, controls phase transitions. Full workspace read access.|Project root context (`AGENTS.md`) and overall state.|
|**Physics Implementation Agent**|High-Capacity Reasoning (e.g., Gemini Pro)|Writes non-commutative rewriting rules (`SymbolicUtils.jl` `@rule`), abstract types, and projector maps. Tool: `replace_file_content`.|Scoped to individual module source files.|
|**Test Generation Subagent**|Fast Low-Latency (e.g., Gemini Flash)|Translates physical limits and oracles into Julia `@testset` suites. Tool: `write_file`.|Scoped strictly to `test/` specifications.|
|**Execution Subagent**|Background Autonomous Worker|Executes test suites and linters. Scoped policy: `commandExecutionPolicy: auto`. Tool: `run_command`.|Isolated from reasoning transcript; streams stdout/stderr back.|
|**Formal Verification Subagent**|High-Capacity Reasoning (e.g., Gemini Pro)|Formalizes algebraic rewriting certificates in Lean 4. Tools: file editing, lake build.|Scoped to `lean/` directory.|

### Deterministic Version Control (Git + DVC) and Documentation Architecture

Version control and documentation must never rely on probabilistic agent adherence. They must be enforced at the operating system and git hook level:



- **The Code vs. Data Boundary:**


    - **Git:** Tracks Julia source (`src/*.jl`), test files (`test/*.jl`), Lean verification scripts (`lean/*.lean`), LaTeX theory documentation (`*.tex`), and `.dvc` pointer files.



    - **DVC:** Tracks intermediate symbolic AST serialization dumps (which can scale to gigabytes), high-dimensional expression trees, and numerical cross-validation datasets (`data/`).



- **Agent Operations for Git/DVC:**


    - For pure code updates, standard Git staging applies.



    - When symbolic execution generates large AST artifacts, the subagent must execute `dvc add data/<artifact>`, stage the resulting `.dvc` file in Git, and run `dvc push`.



    - Autonomous agents must be strictly barred from executing destructive data commands (such as `dvc gc`), and credential files (`.dvc/config.local`) must be excluded via `.gitignore`.



- **System-Level Enforcement:**


    - Configure a Git `pre-commit` hook that parses staged `.jl` files. The hook must reject commits missing standard Julia docstrings containing the implemented mathematical formulas.



    - The hook must inspect file sizes and block any raw data file larger than a set threshold from entering Git without `.dvc` tracking.



    - When a commit fails, AGY intercepts the hook error message and prompts the Implementation Agent to correct the docstring or DVC reference mechanically.




### Inter-Agent Context Protocol & Scaffolding Strategy

1. **Elimination of Inter-Agent Text Files:** As noted, `robots.txt` is irrelevant for CLI agent swarms. Inter-agent communication in AGY operates via internal transcript sharing and structured Markdown declarations.



2. **Context Isolation:** Define overarching project constraints in `AGENTS.md` at the repository root. Define specialized subagents under `.agents/skills/*.md`.



3. **AST Resource Management:** To prevent context overflow, subagents must never print full symbolic expression trees or raw test output dumps to the main transcript. The Execution Subagent must parse and return only the failing test assertions and minimal error traces.



4. **Scaffolding:** Directory trees, package environments (`Project.toml`, `Lakefile`), and boilerplate files must be set up via deterministic POSIX shell scripts rather than using LLM token generation.




### Phase-by-Phase TDD Implementation Guide for `KitaevDerivation.jl`

```
Phase 1: Foundation (Sequential)
└── BasisAndAlgebra.jl (CAR, Non-commutative Projectors)
    ├── Phase 2A: Single-Site Physics (Parallel)
    │   └── SingleSiteSOC.jl (T-P Equivalence, j_eff = 1/2)
    └── Phase 2B: Two-Site Virtual States (Parallel)
        └── TwoSiteKanamori.jl (d4 Multiplet Projectors)
            └── Phase 3: Perturbation Engine (Sequential)
                ├── SchriefferWolff.jl (Lie Solvers S1, S2)
                └── ExchangeExtraction.jl (Pauli Traces)
                    └── Phase 4: Verification & Extensions (Parallel)
                        ├── Lean 4 Translation Validation
                        └── Bond Distortions & Local Potentials (Γ, Γ', DM)
```

#### Phase 1: Foundational Algebra (`BasisAndAlgebra.jl`)

- **Objective:** Establish fermionic Canonical Anti-commutation Relations (CAR) and non-commutative projection algebras without explicit matrices.



- **CAS Ecosystem Constraint:** Use pure `Symbolics.jl` and `SymbolicUtils.jl` rule sets. Avoid mixing with `QuantumAlgebra.jl` to maintain a single, uniform Abstract Syntax Tree (AST) across the pipeline.



- **Physics Oracles to Enforce:**


    - CAR: $\{c_\alpha, c_\beta^\dagger\} = \delta_{\alpha\beta}$ and $\{c_\alpha, c_\beta\} = 0$.



    - Projector Completeness: $P_{\text{singlet}} + P_{\text{triplet}} = I$.



    - Projector Orthogonality: $P_{\text{singlet}} \cdot P_{\text{triplet}} = 0$ and $P_{\text{singlet}}^2 = P_{\text{singlet}}$.




#### Phase 2: Core Physics Subsystems (Parallelizable)

- **Track 2A (`SingleSiteSOC.jl`):**


    - Implement the $T-P$ equivalence $\mathbf{L}_{t_{2g}} \to -\mathbf{l}_{\text{eff}}$.



    - **Oracle:** Verify the energy gap between $j_{\text{eff}}=1/2$ and $j_{\text{eff}}=3/2$ evaluates symbolically to exactly $\frac{3}{2}\lambda$.



- **Track 2B (`TwoSiteKanamori.jl`):**


    - Map the 15-dimensional two-hole $d^4$ manifold onto orbital angular momentum channels $L=0, 1, 2$.



    - **Oracle:** Verify that action by the atomic Hamiltonian yields the exact multiplet eigenvalues: $\Delta E_0 = U+2J_H$, $\Delta E_1 = U-3J_H$, and $\Delta E_2 = U-J_H$.




#### Phase 3: Canonical Transformation & Extraction (`SchriefferWolff.jl`, `ExchangeExtraction.jl`)

- **Objective:** Compute the second-order effective spin Hamiltonian $\mathcal{P}_{1/2} \tilde{H} \mathcal{P}_{1/2} = -\frac{1}{2} \mathcal{P}_{1/2} (T_{-1} S_1^{(+)} + S_1^{(-)} T_1) \mathcal{P}_{1/2}$ and the third-order effective charge density $\delta n_l$.



- **Computational Strategy:**


    - Apply right-to-left state action on the ground manifold to prune terms dynamically instead of multiplying large symbolic operators.



    - Isolate the exchange parameters using Pauli trace identities $\text{Tr}(\sigma^\alpha \sigma^\beta) = 2\delta^{\alpha\beta}$.



- **Physics Oracles to Enforce:**


    - **Jackeli-Khaliullin Cancellation:** Evaluate the Hamiltonian under $J_H = 0$. The isotropic exchange $J$ and anisotropic Kitaev exchange $K$ must evaluate to zero.



    - **Continuous Heisenberg Limit:** In the non-relativistic limit ($\lambda_{\text{SOC}} \to 0$), the anisotropic exchange $K$ must vanish identically.



    - **Point-Group Parity:** Under a $C_2$ rotation exchanging $x \leftrightarrow y$ on a $z$-bond, the exchange tensor components must satisfy $J_{xx} = J_{yy}$.




#### Phase 4: Extensions and Translation Validation

- **Extensions:** Introduce trigonal distortions (direct hopping $t_1, t_3$) to generate off-diagonal symmetric exchange $\Gamma, \Gamma'$, and introduce on-site local potentials $V_0$ to break inversion symmetry and generate antisymmetric Dzyaloshinskii-Moriya (DM) exchange.



- **Lean 4 Validation:** The Julia engine outputs an S-expression or proof certificate of applied rewriting rules. The Lean 4 subagent parses these steps to independently verify the algebraic ring equivalence without re-running the CAS expansions.


