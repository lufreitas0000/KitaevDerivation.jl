# Resource Telemetry & Quota Management Cheat Sheet

This reference details the CLI tools, environment files, and configuration paths governing compute telemetry across the `/home/lucas/Projects` hub.

---

## 1. CLI Commands & Aliases

| Command / Alias | Action | Output / Target |
| :--- | :--- | :--- |
| `proj-compute` | Run real-time ANSI telemetry dashboard | Terminal (Colab, Jules, Quotas, Local models, Hardware) |
| `proj-compute-notify` | Push plain-text native telemetry summary to iOS | iPhone via `ntfy.sh` (distraction-free, no raw markdown) |
| `python3 scripts/compute_tracker.py --json` | Output raw JSON telemetry metrics | Stdout (usable for scripts and subagents) |
| `make yield-report` | Compile empirical yield & ROI report | `orchestrator/benchmarks/YIELD_REPORT.md` |
| `make bench-report` | Calculate Wilson 95% confidence intervals on model accuracy | `orchestrator/benchmarks/REPORT.md` |
| `make api-ledger` | Audit daily OpenAI token pool usage vs. 90% cap | Stdout / notification |
| `make preflight` | Check tools, secrets permissions (0600), and admission headroom | Sanity check suite |
| `proj-status` | Run fast multi-repo git and health audit | Tier 1 & 2 repository sync and dirty state |
| `proj-diff` | Inspect uncommitted diffs or last commit diffstat | Workspace diff summary |
| `proj-pivots` | Aggregate `LOG_DISCOVERY_AND_PIVOTS.md` entries | Workspace failure and pivot journal |
| `proj-agents-sync` | Propagate `.agents/skills` and `.agents/rules` to repos | Downstream synchronization |

---

## 2. Configuration & State Paths

| Component | Path | Description |
| :--- | :--- | :--- |
| **Compute Ledger** | `~/.config/projects/compute_ledger.json` | Stores Colab CU balance, active session burn, and quota settings. |
| **API Keys & Secrets** | `~/.config/projects/agents.env` (0600) | `OPENAI_API_KEY`, `GEMINI_API_KEY`, `JULES_API_KEY`, `NTFY_TOKEN`. |
| **Model Policies & Caps** | `orchestrator/config/models.toml` | Provider caps, pool models, reasoning effort, and USD limits. |
| **Routing Directives** | `orchestrator/config/routing.toml` | Task kind mapping and retry limits. |
| **Execution Policy** | `orchestrator/config/execution.toml` | Gating Antigravity execution (`[antigravity] enabled = false`). |
| **Daily Token Ledgers** | `.agentctl/ledger/YYYY-MM-DD.json` | Token reservations and settled actual counts for OpenAI pools. |
| **USD Spend Ledgers** | `.agentctl/ledger/YYYY-MM-DD-usd.json` | Settled USD charges against prepaid Gemini cloud credits. |
| **Jules Session Log** | `.agentctl/ledger/jules_sessions.json` | List of Jules session IDs dispatched per date. |
| **Attempt Telemetry** | `orchestrator/benchmarks/runs.jsonl` | Immutable log of every model invocation, prompt size, tokens, and outcome. |

---

## 3. Subcommands for Manual Adjustments

```bash
# Set Colab Compute Units balance
python3 scripts/compute_tracker.py colab-set <units>

# Start tracking an active Colab GPU session
python3 scripts/compute_tracker.py colab-start --gpu <T4|L4|A100|G4> --name "<session_name>"

# Stop tracking active Colab session and deduct burned units
python3 scripts/compute_tracker.py colab-stop [--index 0]

# Manually update desktop quota status
python3 scripts/compute_tracker.py quota-set antigravity --weekly <pct> --five-hour <pct>
python3 scripts/compute_tracker.py quota-set codex --status "<Available|Exhausted>" --reset-day "<Friday>"
```
