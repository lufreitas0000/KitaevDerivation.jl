| Date | Module/Context | Obstruction | Pivot/Resolution | Status |
| :--- | :--- | :--- | :--- | :---: |

# Journal of Discoveries, Proof Obstructions & Pivots

This journal preserves critical physics, symbolic derivation, and numerical insights for `KitaevDerivation.jl`. Whenever a derivation strategy fails, an operator representation encounters a bottleneck, or a design pivots, document it here immediately before changing definitions.

---

## Log Entries

| Date | Context / Target Lemma | Obstruction / Bottleneck | Resolution / Architectural Pivot | Status |
| :---: | :---: | :--- | :--- | :---: |
| 2026-10-11 | Phase 3: Projector & Commutator Algebra | Branch conflict between Jules symbolic projection and local pseudospin trace | Isolated local calculations to `feat/phase-3-local-commutators` and rebased `main` against Jules PRs #1 & #2 | RESOLVED |


| 2026-11-18 | Phase 3 branch consolidation (`feat/phase-3-local-commutators`) | Unmerged 4-commit Phase 3 TDD oracle checkpoint (`0aed437`) diverged from rebased `main` (`e4f8430`) | Archived complete bundle to `/home/lucas/Projects/.agentctl/branch-archives/20261118/KitaevDerivation.jl/all_refs.bundle` and deleted branch so `main` stays clean; cherry-pick/port tested extractors cleanly under M2.1 | Resolved |
