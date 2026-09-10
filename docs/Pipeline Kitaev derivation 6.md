# Project Pipeline: Automated Formalization of the Extended Kitaev-Heisenberg Model

This document outlines the software engineering lifecycle for developing a neuro-symbolic framework (Julia + Lean 4) to derive the low-energy effective spin Hamiltonian of strongly correlated Mott insulators.

## 1. Version Control and Documentation Strategy

To ensure reproducibility and traceability of both code and symbolic data, we implement a dual version-control system.

- **Git (Code Version Control):** Tracks all `.jl` (Julia source), `.tex` (LaTeX documentation), and `.lean` (formal proofs) files.
    
- **DVC (Data Version Control):** Tracks large symbolic AST (Abstract Syntax Tree) dumps, pre-computed $15 \times 15$ symbolic matrix inversions, and numerical cross-validation datasets. Symbolic expansions can easily reach gigabytes of text; DVC prevents Git repository bloating while mapping specific ASTs to specific code commits.
    
- **Documenter.jl:** Automated documentation generation. Every Julia function must have a docstring containing the mathematical definition it implements.
    

### Directory Structure

```
KitaevDerivation.jl/
├── .git/
├── .dvc/                   # Data Version Control configurations
├── Project.toml            # Julia dependencies (Symbolics.jl, QuantumAlgebra.jl)
├── src/                    # Main Julia Source Code
│   ├── KitaevDerivation.jl # Main module file
│   ├── BasisAndAlgebra.jl  # CAR and Pauli algebra definitions
│   ├── SingleSiteSOC.jl    # Spin-Orbit Coupling and T-P equivalence
│   ├── TwoSiteKanamori.jl  # d4 intermediate state and multiplet projectors
│   ├── SchriefferWolff.jl  # Perturbation engine
│   └── ExchangeExtraction.jl # Pauli tensor extraction
├── test/                   # TDD Physics Oracles
│   ├── runtests.jl         # Master test suite
│   ├── test_algebra.jl     # Tests for CAR and Projectors
│   ├── test_soc.jl         # Tests for T-P equivalence
│   ├── test_cancellation.jl# Jackeli-Khaliullin cancellation oracle
│   └── test_symmetries.jl  # Point-group and continuous limits
├── lean/                   # Lean 4 Translation Validation
│   ├── Main.lean
│   └── Axioms.lean         # Ring and module definitions
├── data/                   # DVC-tracked artifacts (AST logs, matrices)
└── docs/                   # Documenter.jl generated math documentation
```

## 2. Test-Driven Development (TDD) for Mathematical Physics

Standard software TDD ensures code doesn't crash; Mathematical Physics TDD ensures code doesn't violate the laws of physics.

**The Workflow:**

1. **Write the Oracle (Test):** Before writing any core logic, define the exact mathematical invariant the module must preserve (e.g., $J_H = 0 \implies K = 0$).
    
2. **Define the Type Signature:** Create empty Julia functions with strict type definitions.
    
3. **Prompt the AI Agent:** Provide the agent with the Oracle and the Type Signature.
    
4. **Execute & Iterate:** The AI's code will likely fail the first algebraic simplification. Feed the stack trace and residual algebraic terms back to the AI to refine its substitution rules.
    

## 3. Development Phases & AI Delegation

The project is split into sequential and parallel phases. Foundational algebras must be built sequentially, but independent physical modules can be delegated to different AI agents in parallel.

### Phase 1: Foundation (Strictly Sequential)

**Goal:** Establish the non-commutative algebraic engine.

- **Module:** `BasisAndAlgebra.jl`
    
- **TDD Oracles:**
    
    - Test $\{c_\alpha, c_\beta^\dagger\} = \delta_{\alpha\beta}$.
        
    - Test $P_{\text{singlet}} + P_{\text{triplet}} = I$.
        
    - Test $P_{\text{singlet}} \cdot P_{\text{triplet}} = 0$.
        
- **AI Agent Prompt:** _"Implement a symbolic fermionic algebra in Julia. Define operators that strictly obey CAR. Implement Dirac spin-exchange operators and verify their projection properties."_
    
- **Expected Issue:** AI might try to instantiate explicit $6 \times 6$ or $15 \times 15$ matrices.
    
- **Troubleshoot:** Force the AI to use abstract operator rewriting rules (using `QuantumAlgebra.jl` or `SymbolicUtils.jl` rule sets) instead of dense array instantiations.
    

### Phase 2: Core Physics Subsystems (Parallelizable)

Once Phase 1 is merged, the single-site and two-site physics can be developed simultaneously.

#### Track 2A: The Single-Site SOC

- **Module:** `SingleSiteSOC.jl`
    
- **TDD Oracles:**
    
    - Verify $\mathbf{L}_{t_{2g}} = -\mathbf{l}_{\text{eff}}$.
        
    - Verify the energy gap between $j_{\text{eff}} = 1/2$ and $3/2$ is exactly $\frac{3}{2}\lambda$.
        
- **AI Agent Prompt:** _"Using the `BasisAndAlgebra` operators, construct the_ $t_{2g}$ _SOC Hamiltonian. Output the symbolic unitary transformation to the_ $j_{\text{eff}}$ _basis."_
    

#### Track 2B: The Intermediate $d^4$ State

- **Module:** `TwoSiteKanamori.jl`
    
- **TDD Oracles:**
    
    - Verify eigenvalues of the $d^4$ Kanamori Hamiltonian match exact literature values: $U-3J_H$ (triplet), $U-J_H$ (singlets), $U+2J_H$ (singlet).
        
- **AI Agent Prompt:** _"Construct the two-hole Kanamori Hamiltonian. Block-diagonalize it symbolically using total angular momentum_ $J$ _conservation."_
    
- **Expected Issue:** AI may attempt brute-force diagonalization of a generic $15 \times 15$ matrix, resulting in Abel-Ruffini algebraic hanging.
    
- **Troubleshoot:** Mandate the use of Clebsch-Gordan coefficients and the $P_{\text{singlet}}/P_{\text{triplet}}$ projectors to block-diagonalize _before_ asking the CAS to find eigenvalues.
    

### Phase 3: The Perturbation Engine (Strictly Sequential)

**Goal:** Combine Phase 2 tracks into the Schrieffer-Wolff transformation.

- **Module:** `SchriefferWolff.jl` & `ExchangeExtraction.jl`
    
- **TDD Oracles:**
    
    - **The Jackeli-Khaliullin Oracle:** Evaluate `subs(H_eff, J_H => 0)`. Result MUST be exactly `0`.
        
    - **The Heisenberg Oracle:** Evaluate `subs(H_eff, \lambda => 0)`. Off-diagonal terms ($K, \Gamma$) MUST be exactly `0`.
        
    - **Point-Group Oracle:** Under $C_2$ bond inversion ($x \leftrightarrow y$), the output tensor must be invariant.
        
- **AI Agent Prompt:** _"Implement the second-order resolvent_ $\mathcal{P}_0 H_t \mathcal{R} H_t \mathcal{P}_0$_. Expand the result to_ $\mathcal{O}(t^2/U)$_. Extract coefficients for_ $S_i^\alpha S_j^\beta$_."_
    
- **Expected Issue:** Combinatorial explosion. The expanded polynomial will have thousands of terms. The AI will write code that exhausts RAM.
    
- **Troubleshoot:** Guide the AI to project into the $j_{\text{eff}}=1/2$ basis _immediately_ after the resolvent multiplication, and use normal-ordering algorithms to sort terms canonically before simplifying.
    

### Phase 4: Extensions & Formal Verification (Parallelizable)

**Goal:** Extend to non-Kitaev terms/impurities and verify in Lean.

- **Track 4A (Julia):** Introduce $t_1, t_3$ and $\Delta V_0$ (impurity potential) to generate $\Gamma, \Gamma'$ and Dzyaloshinskii-Moriya (DM) terms. Cross-validate against numerical rational limits.
    
- **Track 4B (Lean 4):**
    
    - **AI Agent Prompt:** _"Parse the AST execution log from Julia. Write a Lean 4 script that verifies the equivalence of `Step N` and `Step N+1` using ring axioms."_
        
    - **Expected Issue:** Lean lacks built-in automation for large polynomial rings.
        
    - **Troubleshoot:** The AI must generate highly granular, step-by-step proofs using `ring` or `noncomm_ring` tactics.
        

## 4. Summary of Dependencies and Workflow

1. `Project.toml` Setup & Base Types $\to$ **(Seq)**
    
2. `BasisAndAlgebra.jl` $\to$ **(Seq)**
    
3. `SingleSiteSOC.jl` & `TwoSiteKanamori.jl` $\to$ **(Parallel)**
    
4. `SchriefferWolff.jl` $\to$ **(Seq)**
    
5. `ExchangeExtraction.jl` $\to$ **(Seq)**
    
6. Extended Impurity Models & Lean Translation $\to$ **(Parallel)**
    

By enforcing the physical limit Oracles (TDD) _before_ the AI generates the symbolic manipulations, you constrain the AI's search space and guarantee mathematical rigor.


---


# System Prompt: Mathematical Physics AI Agent

**Role:**

You are a Senior Mathematical Physics Software Engineer and an expert in neuro-symbolic computation. Your primary role is to assist in developing a rigorous, automated framework to derive low-energy effective field theories (specifically the Extended Kitaev-Heisenberg Model) from strongly correlated multi-orbital Hamiltonians.

**Tech Stack & Ecosystem:**

- **Primary Language:** Julia (for high-performance symbolic and algebraic computation).
    
- **Key Libraries:** `QuantumAlgebra.jl`, `Symbolics.jl`, `Documenter.jl`.
    
- **Formal Verification:** Lean 4 (for topological and point-group symmetry verification).
    
- **Workflow:** Strict Test-Driven Development (TDD) combined with Git/DVC version control.
    

**Core Directives & Engineering Philosophy:**

1. **Physics Oracles First (TDD):** You write mathematical invariants and physical limits (Oracles) as tests _before_ writing core logic. Code that compiles but violates the laws of physics is considered broken.
    
2. **Algebraic over Brute-Force:** You actively avoid explicitly instantiating large multi-dimensional dense matrices (e.g., $15 \times 15$ or $10 \times 10$). Instead, you map problems to non-commutative rewriting rules, Clifford/Lie algebras, and projection operators ($P_{\text{singlet}}$, $P_{\text{triplet}}$, particle-hole symmetries).
    
3. **Combinatorial Discipline:** You are highly aware of combinatorial explosion. You apply projection operators and conservation laws (like total angular momentum $J$) as early as possible in the symbolic pipeline to keep Abstract Syntax Trees (ASTs) manageable.
    
4. **Strict Typing:** You enforce rigorous type signatures for all Julia functions to ensure modularity between single-site, two-site, and perturbative engines.
    

**Interaction Protocol:**

You act as a specialized sub-agent in a larger pipeline. When initiated, do not generate arbitrary physics code. Instead, adopt a standby operational mode:

1. Acknowledge your role.
    
2. Wait for the Lead Engineer (the user) to provide the **Current Project State**, the **Specific Module/Task**, the **TDD Oracles**, and the **Expected Type Signatures**.
    
3. Only once the task is fully specified, output the required code, tests, or mathematical logic, explaining any assumptions made regarding physical hierarchies (e.g., $U \gg \lambda$). Provide the directory and file generation in bash POSIX heredoc, or provide the code block to update the existing file. Each interaction should be an atomic commit,  followed by the code and commit message for GitHub.