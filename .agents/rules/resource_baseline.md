# Workspace Resource Baseline, Quotas & Allocation Directives

This document establishes the canonical theoretical resource breakdown, daily admission ceilings, and adaptive delegation directives across the workspace. All agent instances, automated pipelines (`agentctl`), and human-in-the-loop operators must adhere to these baselines.

---

## 1. Theoretical Resource Breakdown & Daily Capacity

The workspace operates across complimentary data-sharing tiers, prepaid cloud credits, asynchronous remote workers, and interactive IDE sessions. Each resource is bounded by conservative local admission controls (typically a 90% safety threshold) to prevent unintended charges or quota exhaustion.

| Resource Backend | Model / Tier | Daily Provider Limit | Local Safety Cap (90%) | Primary Scope & Optimal Allocation | Estimated Daily Yield |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Google Jules** | Async GitHub Worker | 100 sessions / day (15 concurrent) | 90 sessions / day | • Chapter prose rewrites<br>• Book editorial reviews<br>• Asynchronous repository chores<br>• Multi-lemma proof batches | • 15–20 complete chapter rewrites<br>• OR ~3 full book reviews<br>• OR ~90 focused repo refactors |
| **OpenAI Mini Pool** | `gpt-5.4-mini`<br>(complimentary data sharing) | 2,500,000 tokens / day ($0 cost) | 2,250,000 tokens / day | • Lean Phase B theorem proving<br>• Compiler feedback repairs<br>• Discrete syntax/lemma fixes | • ~90 theorem proof attempts<br>• ~65–70 proved theorems (at 75% pass rate)<br>• OR ~225–450 syntax repairs |
| **OpenAI Large Pool** | `gpt-5.4`<br>(complimentary data sharing) | 250,000 tokens / day ($0 cost) | 225,000 tokens / day | • Lean Phase A interface specs<br>• Non-vacuity witness design<br>• Reviewer adjudication | • 10–12 deep formal specifications or adjudications |
| **Gemini Cloud API** | `gemini-3.8-flash`<br>`gemini-3.1-pro-preview`<br>(prepaid credits: ~$300 BRL) | $8.00 / day cap<br>$50.00 / month cap<br>($2.00 / call max) | Enforced by USD ledger in `models.toml` | • Escalation for Phase A (`gem-pro`)<br>• Escalation for Phase B (`gem-flash`)<br>• Cross-provider review independence | • Flash: ~130–160 fallback tasks/day<br>• Pro: ~25–30 reasoning tasks/day<br>*(Sustainable steady-state: ~$1.60/day)* |
| **Google Antigravity** | Interactive Assistant & IDE | 5-hour rolling prompt window | Generation disabled (`execution.toml`) | • Interactive human pairing<br>• Strategic planning & architecture<br>• Diff inspection & manual verification<br>• Gated judge audits (`agy-judge`) | • 50–80 high-level supervisor turns<br>• 10–12 continuous hours without throttling<br>• Zero bulk code generation |
| **Google Colab CLI** | `colab-cli`<br>(NVIDIA L4 / G4 Blackwell) | Pay-per-compute unit / ephemeral | Auto-terminating single jobs | • Heavy numerical diagonalization<br>• Literature OCR / PDF ingestion | Bounded by project compute units; zero idle leaks |
| **Local Ollama** | `qwen2.5-coder`<br>`qwen3.5` | Unlimited (Local CPU/GPU) | Local machine only | • Offline draft diffs<br>• Format & linting suggestions | Zero marginal cost, zero quota consumption |

---

## 2. Adaptive Delegation Directives ("Rule of Resource Optimization")

### Core Principle
> **"Prioritize zero-cost pools first, provided the model has sufficient reasoning capability for the task complexity."**

Task routing is not rigid; it adapts dynamically to the intrinsic complexity of the mathematical or software requirement:

1. **Mechanical & Standard Theorem Proving (Phase B):**
   * **Route:** `api-fast` (`gpt-5.4-mini`) $\to$ `jules` $\to$ `gem-flash` $\to$ `api-pro`.
   * Fast, low-cost complimentary tokens handle standard lemmas and tactic scripts. If an attempt fails compiler verification, up to 3 bounded feedback retries are run before escalating.

2. **Deep Mathematical Statement Design (Phase A) & Non-Vacuity Witnesses:**
   * **Route:** `api-pro` (`gpt-5.4`) $\to$ `gem-pro` (`gemini-3.1-pro-preview`).
   * Never dispatch high-level interface definitions or non-vacuity witness stubs to small models that risk vacuous formulations or hallucinated signatures. Prioritize the free `api-pro` pool; escalate to prepaid `gem-pro` if the large pool is exhausted or provider independence is required.

3. **Whole-Chapter Prose Rewriting & Manuscript Publishing:**
   * **Route:** `jules` (native branch/patch dispatch).
   * Jules handles large file contexts and full-chapter prose adjustments asynchronously. All mathematical blocks, theorems, labels, and citations are locked byte-for-byte.

4. **Preservation of the Antigravity 5-Hour Limit:**
   * Automated batch scripts must **never** call Antigravity directly for code generation.
   * `orchestrator/config/execution.toml` must enforce `[antigravity] enabled = false`.
   * Antigravity is reserved strictly for operator-level steering, diff reviews, and milestone decisions.

---

## 3. Telemetry & ROI Metadata Tracking

To maintain an empirical baseline of development velocity across nonlinear research tasks:

1. **Granular Attempt Receipts:** Every automated call through `agentctl` records an immutable receipt in `.agentctl/attempts/` and appends a row to `orchestrator/benchmarks/runs.jsonl` detailing:
   * Timestamp, packet ID, task type (`lean.theorem`, `chapter.phaseA`, `document.patch`, etc.).
   * Model requested vs. model returned, token breakdown (input, reasoning, output), and charged USD.
   * Verification outcomes across all gates (`commit_guards`, `ingest_validate`, `verify_commands`).

2. **Automated Yield Reporting:**
   * Running `make yield-report` compiles `runs.jsonl`, `.agentctl/ledger/jules_sessions.json`, and git commits into [`orchestrator/benchmarks/YIELD_REPORT.md`](file:///home/lucas/Projects/orchestrator/benchmarks/YIELD_REPORT.md).
   * Yield metrics tracked include:
     $$\text{Yield}_{\text{theorems}} = \frac{\text{Theorems Proved}}{\text{Total Tokens (M)}}, \quad \text{Yield}_{\text{cost}} = \frac{\text{Proved Theorems}}{\text{Total USD Spent}}, \quad \text{Yield}_{\text{Jules}} = \frac{\text{Accepted Chapters}}{\text{Sessions Completed}}$$

3. **Obstruction & Discovery Journaling:**
   * When an unexpected tactic bottleneck, model capability limit, or architectural obstruction occurs, record the event in the active repository's `LOG_DISCOVERY_AND_PIVOTS.md` before altering interfaces or switching models.
