# Workspace Resource Routing & Offloading Policy

This document establishes the resource selection criteria and offloading protocols across the workspace. Agents, scripts, and subagents must consult this policy before selecting an execution backend or dispatching computational work.

---

## 1. Resource Decision Matrix

| Task Category | Primary Resource | Secondary / Escalation | Method / Tooling | Rationale & Budget Boundary |
| :--- | :--- | :--- | :--- | :--- |
| **Lean Theorem Proving (Phase B)** | **OpenAI Free Pool (`api-fast`)** | **Gemini Flash (`gem-flash`)** | `agentctl theorem` / `prove-file` | Maximizes zero-cost complimentary tokens (`gpt-5.4-mini`) before paid credits. |
| **Lean Statement Design & Spec (Phase A)** | **Gemini Pro (`gem-pro`)** | **OpenAI Pro (`api-pro`)** | `agentctl send --alias gem-pro` or `gemini-pro-api` skill | Requires high reasoning depth and large context windows for anti-vacuity. |
| **Mechanical Compiler Repair** | **OpenAI Free Pool (`api-fast`)** | **Gemini Flash (`gem-flash`)** | `agentctl send --alias api-fast` behind preservation gate | Rapid, low-latency syntax/lemma fixes without consuming reasoning pools. |
| **Repo Maintenance, Docs & Git PRs** | **OpenAI Free Pool (`api-fast`)** | **Gemini Flash (`gem-flash`)** $\to$ **Local Ollama** | `agentctl` / local scripts | Async Jules is deprecated (sunset after Nov 10, 2026); use complimentary pool and local tools. |
| **Literature OCR & GPU Batch Tasks** | **Google Colab CLI (`colab-cli`)** | **Local Server (CPU/MPS)** | `colab-cli run --gpu L4` (or `G4` Blackwell 96GB) | Offloads heavy VRAM / CUDA workloads to Google Cloud; auto-terminates VM. |
| **Local Drafts & Interactive CLI Agents** | **Local Ollama (`qwen3.5:35b-a3b`)** | **OpenAI Free Pool (`api-fast`)** | `qwen-local`, `aider-local`, `aider-hybrid` | Sparse MoE (3B active params/token, ~21 tok/s in 4.9 GB VRAM + 12 GB DDR5); zero cloud quota. |
| **Overnight Batch Extraction & LaTeX Repair** | **Local Ollama (`qwen3.5:35b-a3b`)** | **Local ReAct Retry $\to$ `api-fast`** | `llm/benchmarks/overnight_pipeline.py` | 3-stage cascade behind deterministic quote/LaTeX/prose-retention verifier; capped cloud fallback. |
| **SDK Specs & Upstream API Docs** | **Gemini MCP Docs** | **Web Search** | `gemini_search_docs` / `gemini_get_doc` | Grounded, live upstream docs; avoids deprecated function hallucinations. |
| **Heavy Cloud Compute / Off-Host Benchmarks** | **AWS (Bedrock / Cloud Probe)** | **Colab CLI** | SDK profile `bosonize-probe` via `scripts/aws_readonly_probe.py` | Governed by IAM credentials in `~/.aws/credentials`; run strictly under sandboxed verifier. |

---

## 2. Execution Protocol & Dispatch Standards

### A. Automated Tasks vs. Interactive Sessions
* **Automated Proofs, Batch Runs & Benchmarks**: Must be routed through `orchestrator/agentctl`. Never make direct ad-hoc paid calls from background batch loops.
* **Interactive Chat & Exploratory Coding**: The agent should recommend the optimal resource or invoke specialized skills (`gemini-pro-api`, `gemini-flash-api`, `colab-cli`) after explicit user alignment.

### B. GPU Compute Invariants (`colab-cli`)
* **Default Accelerator**: `--gpu L4` (NVIDIA L4, 24GB VRAM) for standard chapter OCR and physics numerics.
* **Heavy VLM / 72B Models**: `--gpu G4` (NVIDIA RTX PRO 6000 Blackwell, 96GB VRAM) for massive batch inference.
* **Zero-Leak Discipline**: Always use `colab-cli run --gpu <tier> script.py` for headless jobs to guarantee the instance is terminated upon completion, preserving compute unit balance.

### C. Admission Control & Budget Enforcement
* **OpenAI Complimentary Pools**: Governed by `orchestrator/config/models.toml` (`pools.large`, `pools.mini`). Admission checks refuse calls if the daily pool cap (90% safety margin) is reached.
* **Gemini Cloud Credits**: Tracked with daily and per-call USD ceilings in `orchestrator/config/models.toml`.
* **Zero Unintended Charges**: Never fall back from a free or complimentary pool to a paid API without explicit configuration approval.

### D. Overnight Unattended Loops & Local Qwen 3.5 Invariants
1. **Zero-Quota Dispatcher Pattern**: Never run multi-file batch loops turn-by-turn inside Google Antigravity. Dispatch a standalone Python state machine (`setsid nohup ...`) that logs to `.agentctl/ledger/<YYYY-MM-DD>-local.json` and updates `OVERNIGHT_DIAGNOSTIC_REPORT.md` periodically.
2. **Qwen 3.5 Structured Output Flags**: All batch calls to local `qwen3.5:35b-a3b` or `qwen3.5:4b` must explicitly set `"think": False`, `"keep_alive": -1`, and bound `"num_predict"` (`1024–2048`) to prevent runaway `<think>` chains and VRAM KV-cache spillover.
3. **Immortal Loop Fault-Tolerance**: Local Ollama GBNF JSON grammar sampling can occasionally return `HTTP 500` on complex LaTeX backslash sequences. Every client (`chat_json`) and every per-item loop iteration MUST catch `HTTPError`, `URLError`, and `TimeoutError` and return a structured failure dict so the 3-stage retry/escalation cascade continues uninterrupted.
4. **Window-Scoped Repairs**: When repairing LaTeX/Markdown transcripts locally, isolate 20–35 line defective windows rather than rewriting entire chapters, and enforce deterministic verification ($\ge 90\%$ unique prose-word retention + balanced delimiters) before staging repairs.

---

## 3. Sandboxed Verification Gate

Regardless of which resource generated a patch or candidate proof (Jules, OpenAI, Gemini, Colab, or Ollama):
1. **Model output is never trusted implicitly.**
2. Code must be checked through the local namespace sandbox (`llm/runtime/sandbox.py`).
3. Lean code must build against Lake and pass anti-vacuity checks (`lean_minimal_hypotheses`, non-degeneracy witnesses).
4. Julia scripts must verify against independent mathematical specifications or analytical limits.
