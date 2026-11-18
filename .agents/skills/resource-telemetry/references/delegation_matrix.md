# Resource Delegation & Economic Routing Directives

This document details the cost-per-proof economics, model reasoning tiers, and escalation ladders used across the workspace.

---

## 1. Backend Economics & Cost Baseline

| Backend Identifier | Model / Worker | Pricing Model | Context Window | Max Output Tokens | Optimal Workload |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `api-fast` | `gpt-5.4-mini` | $0.00 (Complimentary Mini Pool) | 128k tokens | 32,000 | Lean Phase B theorem proving, compiler feedback iterations, syntax repairs. |
| `api-pro` | `gpt-5.4` | $0.00 (Complimentary Large Pool) | 128k tokens | 64,000 | Lean Phase A interface specs, non-vacuity witness design, difficult lemma decomposition. |
| `jules` | Google Jules | $0.00 (Async Web Worker) | Full Repo Context | Large patches | Asynchronous chapter rewriting, whole-book reviews, multi-file refactoring. |
| `gem-flash` | `gemini-3.8-flash` | $0.75 / $3.75 per 1M (Prepaid USD) | 1M tokens | 32,000 | Secondary escalation for Phase B proofs when OpenAI Mini pool hits 90%. |
| `gem-pro` | `gemini-3.1-pro-preview` | $2.00 / $12.00 per 1M (Prepaid USD) | 200k tokens | 32,000 | High-reasoning escalation for Phase A specs, independent review verification. |
| `colab-cli` | Remote VM (`L4`/`G4`) | 4.80 / 13.50 Compute Units / hr | GPU VRAM (24GB/96GB) | N/A | Heavy literature OCR (Qwen2-VL), numerical Lanczos/ExactDiag benchmarks. |
| `ollama` | `qwen2.5-coder` / `qwen3.5` | $0.00 (Local Hardware) | 32k tokens | Local RAM | Preliminary diff checking, linting, markdown proofreading. |

---

## 2. Escalation Protocol by Task Type

### A. Lean Theorem Proving (Phase B)
1. **Primary (`api-fast`):** Attempt up to 3 bounded compiler-feedback loops in an isolated worktree.
2. **Escalation 1 (`jules`):** If discrete tactics fail or multi-lemma scaffolding is needed, dispatch an asynchronous Jules branch patch.
3. **Escalation 2 (`gem-flash`):** If Jules is delayed or specific single-theorem tactical feedback is needed, invoke `gem-flash` within prepaid USD limits.
4. **Final Escalation (`api-pro`):** For deep mathematical obstructions requiring high-order proof planning before altering interfaces.

### B. Mathematical Interface Design (Phase A)
1. **Primary (`api-pro`):** Generate complete data declarations and one-sorry theorem stubs with non-vacuity witnesses.
2. **Independent Review (`gem-pro`):** Use Gemini Pro to conduct an independent cross-provider review of carriers, signs, hypotheses, and downstream contracts.

### C. Whole-Chapter Prose & Book Review
1. **Primary (`jules`):** Dispatch disjoint chapter tasks. All theorem blocks, citations, labels, and mathematical equations are frozen byte-for-byte.
2. **Local Coordination (`Codex` / `Antigravity`):** Verify patches through sandboxed book build, check diffs against whitelist gates, and assemble combined book candidates.

---

## 3. Admission Gate Invariants

1. **Conservative Reservation:** Before an API call is dispatched, `admission.py` reserves an estimated token ceiling. The call is rejected if the pool would exceed 90% capacity.
2. **Atomic Settlement:** Upon receiving the model response, actual tokens charged (input + reasoning + output) are settled in the daily ledger.
3. **Zero Paid Spillover:** No fallback from a free pool to a paid API is allowed automatically. If `api-fast` is exhausted, tasks are deferred unless the user explicitly specifies an escalation alias.
