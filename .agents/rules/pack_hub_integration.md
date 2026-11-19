---
trigger: model_decision
description: Federation workspace.toml registration, cross-project interfaces, and hub pulse synchronization.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Pack: Projects Hub Integration, Risk-Aware Routing, and Telemetry

## 1. Zero-Fatigue Notifications
Long-running jobs (> 3 min) and unattended workflows must adhere to zero-fatigue notifications:
- Pushes are sent ONLY when the human user must take concrete action (failure, review, blocked, quota exhausted).
- Routine successes and nested steps remain completely silent.
- Every notification must include an actionable `do` command:
  `python3 scripts/notify.py --type action --project <name> --what <desc> --do <concrete-command>`

## 2. LLM Code Sandboxing
- All model-generated code execution must run inside the namespace sandbox (`llm/runtime/sandbox.py`).
- Network access is disabled, credential directories hidden, and secrets scrubbed.
- Never bypass the sandbox (`LLM_SANDBOX=off`) for model outputs.

## 3. Adaptive Resource Routing & Jules Sunset Schedule
Follow `.agents/rules/resource_routing.md` and `.agents/rules/09_model_risk_and_delegation.md`:
- Route tasks by **Workflow Role (`W1–W4`)** and **Scientific Risk (`R0–R3`)**.
- Lean Phase B & mechanical repairs: complimentary pools via `agentctl`.
- Deep Phase A reasoning & dense docs: Gemini Pro / OpenAI Pro.
- GPU computation & heavy batch OCR: Google Colab CLI (`colab-cli`).
- **Google Jules Sunset (Oct 29, 2026 Announcement):** Jules remains usable for completing active sessions through **November 11, 2026**, transitions to **read-only mode** from November 11 through December 30, 2026, and shuts down completely on **December 31, 2026**. Repositories must use `agentctl` runners, local models, and scoped subagents for new work.

## 4. Cross-project scientific handoffs

- Use repository-owned Issues for bounded requests from theory, laboratory or
  publishing fronts; direct changes go through reviewed PRs.
- AI agents may originate Issues and undertake bounded, policy-authorized
  work autonomously. A separate reviewer (human or AI) assesses the evidence;
  an originating agent does not certify its own issue.
- Link experiments, proofs and published notes to their authoritative
  source repository. Preserve immutable scientific hypotheses and append-only
  evidence histories; record changed plans in adaptive roadmaps.
- The projects hub coordinates discoverability and handoffs; the personal
  website coordinates public-facing explanations. Neither supersedes a
  child project's scientific governance or justifies publishing private data.
- Optional visual language:
  `docs/EDITORIAL_DESIGN_GUIDE.md` in the canonical governance repository.
