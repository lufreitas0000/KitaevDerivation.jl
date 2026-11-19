---
trigger: always_on
description: Federation hub sprint authority, non-vacuity checks, and mandatory uv hardlinked Python environments.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Workspace architecture and development scope

`workspace.toml` is the repository inventory and stack/tier authority.
`/home/lu/Projects/ACTIVE_FOCUS.md` is the current sprint authority; read it
before starting work. Tiers determine audit coverage, not permission to expand
implementation scope. Root files belong to the hub; child projects are independent
Git repositories, never automatically submodules of the hub.

## Current allocation

Read ACTIVE_FOCUS.md for the latest project-specific authorization; dated
infrastructure snapshots do not determine current chapter status. 

## Domain and verification contracts
.

Local agents implement, test and review repository changes. Browser LLMs receive
bounded packets and return candidate files; whitelist, interface checks and local
verification decide acceptance. Colab performs background compute/transcription;
Jules works only on explicitly assigned jobs. Configured API/Jules transports and browser handoffs share acceptance gates. No subscription or model
availability is assumed. See the hub README routing table, `resource_routing.md`, and llm/PROTOCOL.md.

## Resource allocation and offloading

Consult `.agents/rules/resource_routing.md` for resource routing logic across Jules,
OpenAI Complimentary Pools, Gemini API (prepaid credits), Google Colab CLI (`colab-cli`),
Local Ollama, and AWS. Automated tasks route through `orchestrator/agentctl` with
strict admission control; interactive work leverages specialized skills; compute jobs
on Colab enforce auto-terminating `--gpu L4`/`G4` execution.

Keep valid GitHub remotes on lufreitas0000 for active repositories. Preview all
external candidate diffs and keep independent specifications/oracles. Compiler
success and non-vacuity/physical correctness are separate requirements. Use the
five-column discovery journal before changing definitions or pivoting algorithms.

## Python virtual environment standard (`uv`)

All Python virtual environments across repositories and Git worktrees **must** be created and synchronized with **`uv`** (`uv venv && uv sync` or `uv pip install`) on the native ext4 filesystem (`/home/lu/...`), never with `python -m venv`, `virtualenv`, `poetry`, or plain `pip install`:
- **Same-ext4 hardlinking:** Keeping environments under `/home/lu/Projects/...` hardlinks identical wheel files (e.g. multi-GB PyTorch/CUDA libraries) from `~/.cache/uv` instead of duplicating physical storage.
- **Immutable `site-packages/`:** Never edit files in-place inside `.venv/lib*/python*/site-packages/` (since hardlinked inodes are shared with `~/.cache/uv`); install repo packages cleanly in editable mode or via `uv sync`.
- **Custom C++/CUDA extensions:** Only pass `--no-build-isolation` if a local compiled extension requires headers from the active environment.

