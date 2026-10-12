# Workspace Architecture & Domain Directory Rules

This rule file specifies the global directory layout, boundaries, and domain purposes across `/home/lucas/Projects`.

---

## 1. Directory Taxonomy & Domains

| Directory | Domain & Purpose | Key Repositories / Subpackages |
| :--- | :--- | :--- |
| **`climbing/`** | LuaLaTeX Climbing Guidebooks & Typography | `cg-engine` (v1.5 engine), `cg-serra-caiada` (submodule), `cg-serra-do-cuo` (submodule), `climbing-guide` (archived) |
| **`nexus/`** | Multimodal Academic Ingestion & Knowledge Garden | `nexus-engine` (Python monorepo via `uv`), `nexus-workspace` (DVC data vault & `nexus.db`) |
| **`xxz-multimethod-benchmark/`** | 1D XXZ Spin-$1/2$ Chain Multi-Method Benchmark | `lean/` (`ExactDiag`, `BetheAnsatz`, `Bosonization`, `DMRG`), `julia/` (`LeanED`, `IntegrableSpins`, `Bosonization`, `DMRG`), `benchmarks/` |
| **`Lean/`** | Exact Formal Mathematical Physics Ecosystem | `bosonize-lean` (1D AQFT/VOA), `finite-QMB` (Tasaki/LSM/AKLT), `qed3-duality`, `infinite-QMB-QFT-CFT`, `lean-boilerplate`, `learning_lean` |
| **`Julia/`** | Symbolic & Numerical Hamiltonian Derivations | `KitaevDerivation.jl` (Kitaev-Heisenberg automated derivation) |
| **`References/`** | Academic Literature, OCR & Markdown Transcripts | `references-transcripts` (Git tracked), `reference-source` (PDF vault), `scripts` (Colab OCR & Jules orchestration) |
| **`latex_notes/`** | LaTeX Physics Monograph Workspaces | `JW and gauge field` (24 notes on Jordan-Wigner & dyons), `qed3-duality/` (`book`, `workplace`, `references-lightweight`) |
| **`islp/`** | Machine Learning & Statistical Computing | Python exercises and implementations of *An Introduction to Statistical Learning* |
| **`archive/`** | Retired Experiments & Historical Predecessors | `legacy_nexus/` (`arxiv_scraper`, `kindle`, `pdf_ingestion_pipeline`, `spliter`), `semantic_document_engine`, `recsys_engine`, `benchmark_qwen` |

---

## 2. Active Focus & Sprint Governance

The user works across high-complexity domains. To prevent context thrashing, all agents must adhere to the current sprint priorities defined in [`ACTIVE_FOCUS.md`](../../ACTIVE_FOCUS.md):

* **Active Deep Work Focus:** 
  1. `xxz-multimethod-benchmark` Milestone 1 (ExactDiag: Hilbert space integer bijection in Lean 4 + Gosper's hack in Julia `LeanED`).
  2. `Lean/finite-QMB` (Hal Tasaki formalization).
* **Parallel Foundation Track:**
  * Active study and exercise implementation of **Category Theory and Lean 4 foundations** in `Lean/learning_lean/` (Milewski's *Category Theory for Programmers*, monoidal categories, functorial quantum mechanics, Mathlib algebraic abstractions).
* **Background Automation:**
  * Google Colab (72B VLM) + Google Jules concurrent agent sessions finishing reference book transcriptions.
* **Icebox / Standby:**
  * Do not proactively initiate or expand work in `islp`, `climbing/`, or secondary `archive/` tools without explicit user request.

---

## 3. Toolchain & Environment Invariants

* **Python:** Managed with `uv` (never bare global pip installs). Virtual environments must live in `.venv` or be managed via `pyproject.toml`.
* **Lean 4:** Managed with `elan` and `lake`. Mathlib oleans are cached using `lake exe cache get`. Core libraries use `-DwarningAsError=true`.
* **Julia:** Managed with standard Julia `Pkg`. Packages use project-local environments (`Project.toml`).
* **Git Health:** Check workspace sync status using `proj-status` (`python3 status.py`). All repositories must maintain private GitHub remotes on `lufreitas0000`.
