---
trigger: model_decision
description: Milestone task numbering (T1..TN), evidence verification, and sprint closure gates.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 06: Milestone Progress and Commit-Level Handover

The planning hierarchy and task lifecycle are defined by Rule 05: Project Management. This rule specifies how milestone state is maintained on development branches.

## State and roadmap ownership

1. The roadmap at doc/MILESTONE_ROADMAP.md owns the persistent Phase/Milestone backlog and milestone acceptance gates.
2. PROJECT_STATE.yaml records the active phase, active milestone, current active tasks, completed milestone evidence, verified invariants, and blockers.
3. The state and roadmap describe the development branch that owns the active milestone. Do not copy in-progress state to unrelated branches or governance/project-governance.
4. Do not store branch name, working-tree cleanliness, HEAD, or live CI status in PROJECT_STATE.yaml.

## Atomic progress updates

1. Update PROJECT_STATE.yaml and doc/MILESTONE_ROADMAP.md in the same commit whenever a milestone opens/closes or its scope, task set, acceptance criteria, blockers, or verification status materially changes.
2. Include relevant implementation/test files in that same commit when the change alters the active task's deliverables or evidence.
3. Routine commits that do not change milestone scope, task status, or verification evidence need not rewrite both progress files.
4. For multi-file updates, create all blobs, one tree, and one commit, then advance the branch ref with an expected-head check. Do not use independent file commits for a logically atomic state transition.

## Active task records

- Keep task IDs T1, T2, ... only for the active milestone's current execution set.
- Each task records exact target files, analytical/engineering contracts, dependencies, and validation commands.
- Mark planned files as planned; do not imply they already exist.
- When a task is complete, record evidence and outcome. When the milestone closes, move the verification summary to milestone history and remove the active task list.
- Do not retain the former package labels M1.4.5a etc. as a second task taxonomy.

## Evidence discipline

1. Mark a milestone or task completed only when deliverables exist and acceptance criteria are met.
2. Local WSL validation remains awaiting_local_validation until the user reports exact commands and outcomes. Never infer test success from code inspection or GitHub writes.
3. Distinguish analytical proof, literature agreement, numerical convergence, automated tests, and user-run validation.
4. A test passing establishes only its tested property and parameter domain. It does not prove a general mathematical statement.
5. Record prior commit provenance only when known; never guess the SHA of a commit being created.
6. A fresh agent reads AGENTS.md, applicable rules, PROJECT_STATE.yaml, and doc/MILESTONE_ROADMAP.md, then inspects branch/head and working-tree state before editing.

## Next-action handover

At the end of a substantial milestone task, report:
- branch and commit/PR state;
- completed task IDs and evidence;
- commands run and outcomes, including skipped checks;
- blockers, assumptions requiring review, and the exact next task.

## PG-10 compatibility

[PG-10](10_atomic_unit_of_work.md) adds lawful transition and repository-first
resumption obligations. Native records retain authority; structured events require
separate adoption. The reference toolkit reports mechanical findings, not scientific
acceptance. No child migration or universal file renaming follows from this rule.
