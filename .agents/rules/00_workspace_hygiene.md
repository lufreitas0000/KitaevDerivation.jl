---
trigger: always_on
description: Working-tree hygiene, preservation of unrelated edits, and module granularity invariants.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 00: Workspace Hygiene and Repository Layout

## 1. Working-tree hygiene

1. Inspect `git status --short --branch` and the existing diff before editing. Preserve unrelated user changes.
2. At task completion, remove only temporary files created by the task when they are no longer needed. Do not require a globally clean working tree: intentional untracked research files, user data, and pre-existing changes must be preserved.
3. Generated artifacts belong in ignored build/cache locations where practical. Do not add broad ignore rules merely to hide unexplained files; inspect and classify each artifact.
4. Never stage or commit generated snapshots, debug dumps, temporary scripts, caches, or raw simulation output unless a reviewed deliverable explicitly requires them.
5. Do not run cleanup commands that may remove user data or pre-existing files without explicit authorization. See Rule 01.

## 2. File and module granularity

1. Give each source, test, script, and documentation file a coherent primary responsibility.
2. Prefer concise modules and focused notes, but do not enforce a universal line-count limit. Split a file when doing so improves cohesion, navigation, testing, or reuse; avoid fragmentation that obscures the argument or interface.
3. Keep tests focused on a behavior or contract. Use separate test modules when their subject matter or fixtures differ materially.
4. Avoid monolithic audit scripts. Reuse the repository's existing scripts and test structure before adding new tooling.

## 3. Repository layout

The following describes the current layout and intended responsibilities. A directory described as an intended or conditional layer is not assumed to exist.

- `.agents/rules/`: normative operational, engineering, testing, safety, and scientific-documentation policies.
- `doc/adr/`: architecture decision records, named `ADR-NNN-<slug>.md`.
- `doc/governance/`: governance architecture and repository-level policy records.
- `doc/rnd/`: exploratory theoretical and numerical research notes.
- `doc/reference/`: reference material, including the imported thesis sources; treat source literature as reference material, not as production documentation.
- `src/kitaev_mf/domain/`: mathematical entities, lattice structures, parameters, state, and interfaces. Keep independent of concrete services and infrastructure.
- `src/kitaev_mf/services/`: physics and computational algorithms built on domain abstractions.
- `src/kitaev_mf/infra/`: concrete numerical backends and external I/O.
- `src/kitaev_mf/app/`: a possible application/workflow layer; create it only when an actual orchestration requirement justifies it.
- `test/unit/`: focused unit tests. The current suite is under `test/`; add `test/integration/` only when integration-level contracts warrant a distinct location.
- `scripts/`: repository utilities such as snapshot generation.

Do not create directories solely to make the tree conform to this description. Follow existing package and test conventions, and update this rule when the architecture materially changes.
