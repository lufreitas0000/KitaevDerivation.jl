# Current sprint — KitaevDerivation.jl / M2.1

Owning milestone: M2.1 (see [HORIZON.md](HORIZON.md))
Machine state: [PROJECT_STATE.yaml](PROJECT_STATE.yaml) (authoritative for task statuses)

## Scientific / engineering objective
Consolidate repo to single `main`, archive & record Phase 3 TDD checkpoint `0aed437`, and establish Four-Record + HORIZON + UoW governance.

## Implementation strategy
Preserve clean `main` while porting audited TDD oracle tests from the archived `0aed437` bundle incrementally.

## Scope and non-goals
Owns Julia symbolic/numerical operator engine (`src/`, `test/`) and derivation docs (`docs/`); formal Lean proof checks remain strictly decoupled in Lean repositories.

## Current bounded tasks
- `T1` in `PROJECT_STATE.yaml`: Adopt Four-Record governance, document archived Phase 3 checkpoint 0aed437, and sync .agents/

## Independent acceptance and reproduction
- `python3 /home/lucas/Projects/scripts/uow.py check --repo KitaevDerivation.jl`

## Blockers and owner choices
- None blocking governance alignment; see repo-owned verification commands above.

## Exact Next Step
- Port verified Phase 3 Appendix A macroscopic commutator oracles from archived commit `0aed437` into tested `src/ExchangeExtraction.jl` modules.
