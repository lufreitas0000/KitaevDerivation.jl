<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 09: Two-Dimensional Task-Risk Classification, Model Delegation & Scientific Circuit Breakers

To maximize independently verified scientific progress per unit of limited model quota without compromising mathematical rigor, all agentic work is classified along **two independent dimensions**: **Workflow Role** and **Scientific Risk**.

---

## 1. Dimension 1: Workflow Roles (`W1–W4`)

| Role | Responsibility | Typical Deliverable |
| :--- | :--- | :--- |
| **W1 — Scientific Specification** | Formulating mathematical assumptions, domains, representations, conventions, boundary conditions, limiting cases, and falsification criteria. | Locked task contract (`.agents/tasks/TASK_*.md`) or Front 1 R&D note (`doc/rnd/`). Supports both wave/sprint/atomic-task workflows (`kitaev-mf`) and phase/milestone workflows (`kitaev-walk-geometry`, `bosonize-lean`). |
| **W2 — Scoped Implementation** | Translating an explicit mathematical specification into modular code (`domain/`, `services/`, `infra/`) and unit tests (`test/` or `tests/`). | Verified code candidate in an isolated branch or worktree. |
| **W3 — Mechanical Processing** | Codebase exploration, symbol/call-graph lookup, formatting, linting (`ruff`), type annotations, fixture generation, and data plotting scripts. | Compact read-only summary or deterministic mechanical patch. |
| **W4 — Independent Scientific Audit** | Attempting to falsify both the mathematical contract and the implementation (`role_adversarial_referee.md`: F1 wrong statement, F2 vacuous/tautological test, hidden idealizations). | Structured `PASS` / `REJECT` referee report with numbered blocking defects `[B1..]`. |

---

## 2. Dimension 2: Scientific Risk Levels (`R0–R3`)

Model selection is governed by **scientific risk**, not merely whether a file is prose, LaTeX, or code. A one-line change to a Fourier sign, Majorana normalization, or gauge projection rule is **Risk R3**, whereas a 200-line plotting boilerplate script is **Risk R0**.

| Risk Level | Definition & Examples | Configurable Starting Model Hypothesis | Verification & Acceptance Gate |
| :--- | :--- | :--- | :--- |
| **R0 — Mechanical / Cosmetic** | Formatting, docstrings, comments, lint fixes, read-only grep exploration, or tabular `.dat` $\to$ `pgfplots` wiring with zero change to formulas or thresholds. | • **Local Ollama**: `qwen3.5:35b-a3b` (`aider-local`, `qwen-local`)<br>• **Codex**: `gpt-6-luna` (`medium`)<br>• **Antigravity**: `flash` (`@code-scout`) | Deterministic repository checks (`make lint`, `make verify`). |
| **R1 — Standard Numerical / Algorithmic** | Implementing a standard algorithm or helper function whose mathematical contract, inputs, outputs, and analytical reference values are completely locked. | • **Codex**: `gpt-6.1-terra` (`medium` effort; avoid `xhigh`)<br>• **Antigravity**: `flash` (`@impl-worker`)<br>• **`agentctl`**: `api-fast` / `gem-flash` | Passes repository test suite (`make verify`) and independent analytical/limiting-case checks. |
| **R2 — Physical-Model-Sensitive** | Implementing or modifying Hamiltonians, Green functions, Pfaffian flux operators, Bogoliubov spectra, or finite-size scaling fits where subtle sign/prefactor errors can occur. | • **Spec (W1)**: `gpt-6.1-sol` or `Gemini 4 Argon` / `Pro`<br>• **Impl (W2)**: `gpt-6.1-terra` (`medium`) or `flash` strictly under locked contract<br>• **Audit (W4)**: Independent strong model (`Sol` or `Argon`/`Pro`) | Must verify against an **independent analytical limit or alternative representation** (never a self-referential test written from the same untested formula). |
| **R3 — High-Consequence Mathematical / Architectural** | Defining new physical approximations, gauge-projection rules, non-vacuity witnesses (Lean Phase A), or adjudicating discrepancies between theory and numerics. | • **Primary**: `gpt-6.1-sol` (`high`), `Gemini 4 Argon` / `Pro`, or `agentctl` `api-pro` / `gem-pro` | Explicit human sign-off on contract thresholds + cross-model adversarial referee (`W4`). |

*(Note: `gpt-6.1-terra` at `medium` and `gpt-6-luna` are configurable starting hypotheses to be evaluated empirically via `quota_telemetry_daemon.py` against accepted task yield and human rework time, not universal guarantees of lower cost).*

---

## 3. Enforceable Technical Controls vs. Behavioral Guidance

1. **Enforceable Technical Controls (Hard Gates):**
   - **`agentctl` Admission & Pool Ledgers (`orchestrator/agentctl/admission.py`):** Hard pre-call reservation caps on API pools (`api-fast`, `api-pro`, `gem-flash`, `gem-pro`) and zero automatic fallback to paid API models.
   - **Namespace Sandboxing (`llm/runtime/sandbox.py`):** OS-level network isolation and credential scrubbing during automated verification (`LLM_SANDBOX` never disabled).
   - **Parent Session Sandbox Mode (`.codex/config.toml` / CLI flags):** In OpenAI Codex, custom agent files (`.codex/agents/*.toml`) inherit the parent session's `sandbox_mode` (`read-only` or `workspace-write`) and `approval_policy`; a subagent TOML file cannot enforce an independent OS sandbox on its own.
2. **Behavioral Prompt Guidance (Requires Operator & Verifier Oversight):**
   - **Differentiated Circuit Breaker:**
     - *Clear Implementation / Mechanical Defects ($\le 2$ Repair Attempts):* If a test fails due to a syntax error, import mismatch, type annotation, or a clear transcription typo against an **unchanged mathematical contract**, the implementation worker (`W2`/`W3`) may run up to **2 bounded repair attempts** using the repository's configured check (`make verify`).
     - *Mathematical Contract / Physical Invariant Failures (0 Blind Changes):* If a physical identity, symmetry, conservation law, or analytical limit fails and cannot be explained by a simple mechanical typo, the worker must **stop immediately** without guessing factors of $2$ or $-1$, altering mathematical definitions, or relaxing test tolerances (`atol`/`rtol`).
   - **Structured Task Handoff Metadata:** Every task packet (`.agents/tasks/TASK_*.md` or wave/sprint brief) should record: target repository and base commit, contract SHA-256 or ID, writable file whitelist, exact verification commands, allowed provider/accounting surface, attempt budget, independent reviewer (`W4`), and human acceptance owner.
