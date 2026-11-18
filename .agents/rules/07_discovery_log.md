<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 07: Discovery and Obstruction Journaling

## 1. Requirement and Authority
Every technical repository in the workspace must maintain a `LOG_DISCOVERY_AND_PIVOTS.md` at its root. Any mathematical proof obstruction, algorithmic bottleneck, numerical instability, or design pivot must be recorded before pivoting definitions or discarding approaches.

## 2. Mandatory 5-Column Schema
All entries must conform to the strict five-column table format:

| Date | Module/Context | Obstruction | Pivot/Resolution | Status |
| :--- | :--- | :--- | :--- | :---: |
| YYYY-MM-DD | Exact path or symbol | Precise description of failure mode or obstruction | Rationale and technical direction taken | `Active` / `Resolved` / `Deferred` |

## 3. Operating Invariants
1. **Never Silently Pivot:** If a theorem, tactic, or solver fails, log the exact error or bottleneck first.
2. **Preserve Dead Ends:** Exploratory failures contain valuable physical and mathematical information preventing future agents from repeating identical traps.
3. **Commit Association:** Include the discovery log update in the same Git commit that implements the pivot or documents the blockage.

## 4. Research-specific evidence and interpretation

The five-column table in §2 stays the **mandatory concise index**. For consequential mathematical or scientific changes, link the row to an existing `doc/rnd/` record, a versioned detailed section below the table, or another project-local research note containing:

1. **Question and scope:** assumptions, Hilbert-space/parameter domain, limiting regime, conventions, intended quantity, and the interpretation being tested.
2. **Observation or obstruction:** an explicit equation, counterexample, proof state, error message, empirical measurement, or reproduced numerical result; preserve unsuccessful attempts.
3. **Provenance and quality:** source commit/path, precise commands and actual outcomes, dataset/receipt locations, tolerances and uncertainties if justified. Explicitly say "not run" rather than inferring execution.
4. **Decision and competing explanations:** alternatives considered, what the evidence establishes and does *not* establish, remaining conditional claims, rationale for changing method or scope, and what could falsify the interpretation.
5. **Consequences and handoff:** affected backlog IDEA, roadmap milestone, sprint task, Issue/PR or immutable hypothesis contract, with `TODO(owner)` decisions and superseding record links as necessary.

Distinguish **mathematical proof**, **numerical finite-domain verification**, **empirical observation**, **physical approximation**, and **heuristic proposal**. A line in the log is not scientific acceptance; its `Resolved` status means the *reported obstruction/decision* has been addressed under the stated evidence, not that an associated physics conjecture has been proved. Do not relabel previously accepted historical entries merely to create uniformity.

## 5. Deterministic logging automation

- Use the opt-in `scripts/planning_records.py` reference CLI in this governance repository (or a repository-local compatible wrapper) to lint adopted planning records and generate a **draft** five-column entry from explicitly supplied fields. A new log row belongs inside the existing Rule 07 table, not appended after unrelated Markdown sections.
- Require an explicit `--apply` action for writing; default to printing the proposed entry. An automated timestamp is metadata, never evidence of a performed experiment. Reject multiline or malformed table fields and escape Markdown pipes.
- A script must not auto-summarize a Git diff as scientific justification, turn a failed experiment into `Resolved`, fabricate an uncertainty bar, or alter registered hypothesis status. Do not introduce opaque background agents or Git hooks that write to research records without inspection.
- Extend existing logging mechanisms in place where feasible; do not require a central Python dependency for Lean, Julia, or LaTeX projects. Human review of physical definitions, interpretation, alternatives, and provenance remains mandatory.

## PG-10 compatibility

[PG-10](10_atomic_unit_of_work.md) adds lawful transition and repository-first
resumption obligations. Native records retain authority; structured events require
separate adoption. The reference toolkit reports mechanical findings, not scientific
acceptance. No child migration or universal file renaming follows from this rule.
