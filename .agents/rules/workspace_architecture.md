# Workspace architecture and development scope

`workspace.toml` is the repository inventory and stack/tier authority.
`/home/lucas/Projects/ACTIVE_FOCUS.md` is the current sprint authority; read it
before starting work. Tiers determine audit coverage, not permission to expand
implementation scope. Root files belong to the hub; child projects are independent
Git repositories, never automatically submodules of the hub.

## Current allocation (user decision, October 13, 2026)

Primary development is the Web-LLM packet/ingestion pipeline. Defer XXZ,
bosonize-lean and finite-QMB implementation until pipeline readiness. Bounded
learning_lean study is parallel; reference transcription/review is background.
Do not start standby projects without explicit direction.

## Domain and verification contracts

Lean specifies and proves; Julia performs numerical/symbolic computation.
Keep their artifacts in their respective projects and package directories.
Python uses uv-managed environments if dependencies are needed; the hub pipeline
uses only Python 3.11 standard library. Lean uses elan/Lake and project CI.
Julia uses project-local environments. Publication projects own their assets.

Local agents implement, test and review repository changes. Browser LLMs receive
bounded packets and return candidate files; whitelist, interface checks and local
verification decide acceptance. Colab performs background compute/transcription;
Jules works only on explicitly assigned jobs. Optional model APIs may transport
packets later, but do not bypass acceptance gates. No subscription or model
availability is assumed. See the hub README routing table and llm/PROTOCOL.md.

Keep valid GitHub remotes on lufreitas0000 for active repositories. Preview all
external candidate diffs and keep independent specifications/oracles. Compiler
success and non-vacuity/physical correctness are separate requirements. Use the
five-column discovery journal before changing definitions or pivoting algorithms.
