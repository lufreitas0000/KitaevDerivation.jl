# Research and engineering idea backlog — KitaevDerivation.jl

**Authority:** Non-committal local exploration queue (`IDEA-NNN`), distinct from `HORIZON.md` and `CURRENT_SPRINT.md`. Cross-project proposals live in [`/home/lucas/Projects/docs/NEXT_PROJECTS_INCUBATOR.md`](file:///home/lucas/Projects/docs/NEXT_PROJECTS_INCUBATOR.md).

## IDEA-001 — Port Appendix A macroscopic commutator TDD suite from archived `0aed437` bundle
Status: inbox
Question and motivation: Which assertions in `0aed437:test/test_appendix_a.jl` pass unchanged on `main` and which expose real missing sign factors in `ExchangeExtraction.jl`?
First inexpensive falsification or feasibility check: Inspect primary artifacts and write bounded test/check.
