---
trigger: model_decision
description: Four-Record planning system (PROJECT_STATE.yaml, CURRENT_SPRINT.md, HORIZON.md, BACKLOG.md) and cross-repo issues.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 05: Project Management — Phases, Milestones, Tasks, and Sprints

## 1. Purpose and planning hierarchy

Use a lightweight, Scrum-inspired process to coordinate implementation and research. The repository is not required to reproduce the full Scrum framework; ceremonies, roles, and artifacts should remain proportional to a small research-software project.

The planning hierarchy is:

Phase → Milestone → Task

- **Phase** (Phase N): a macro-horizon describing a physical or engineering regime. A phase groups related strategic outcomes and may span multiple releases.
- **Milestone** (M<phase>.<index>): a persistent strategic backlog item and acceptance gate. A milestone states its objective, scope, assumptions, dependencies, target deliverables, and acceptance criteria. A nested milestone may use an additional suffix, e.g. M1.4.5, when explicitly subordinate to a parent milestone; do not use extra numeric components to encode tasks or batches.
- **Task** (T<index>): a short-lived execution unit belonging only to the active milestone's current sprint. Task numbering restarts at T1 when a new milestone becomes active. A task must have a concrete outcome, exact target files or interfaces, analytical/engineering contracts, and verification commands.

Milestones persist in the roadmap. Tasks are not a second strategic backlog: do not pre-allocate task IDs or granular implementation plans to future milestones.

## 2. Roadmap and project-state responsibilities

- doc/MILESTONE_ROADMAP.md is the persistent product/research backlog. It records phases, milestone objectives, dependencies, and acceptance gates.
- PROJECT_STATE.yaml is the concise current-state record. It identifies the active phase and milestone, the active milestone's current tasks, completed milestone evidence, verified invariants, and blockers.
- R&D notes contain derivations, exploratory calculations, failed approaches, and scientific qualifications. A roadmap entry is not evidence that a scientific claim has been proved.
- Tests and reproducibility artifacts provide evidence only for their actual scope. Keep analytical proof, numerical tests, finite-size evidence, and approximations distinct.

Do not duplicate full task descriptions in both files. The roadmap should identify the active milestone and link to the state record for its current task breakdown. The state record should not reproduce the entire future roadmap.

## 3. Milestone contract

Every roadmap milestone must define:

1. Stable ID, phase, title, and status.
2. Objective and physical/software scope.
3. Assumptions, conventions, dependencies, and non-goals where relevant.
4. Target deliverables or repository areas. Mark paths that do not yet exist as planned targets.
5. Acceptance criteria that are observable and independently reviewable.
6. Verification evidence when closed, including exact commands, relevant tests, analytical records, and validation provenance.

Use statuses consistently: backlog, ready, active, blocked, and completed. A milestone is completed only after its acceptance gate is reviewed. Do not promote a planned numerical benchmark or conjectural identity into a verified invariant merely by listing it as a criterion.

Future milestones must remain at milestone granularity. Do not add numbered tasks, sub-batches, or implementation schedules until that milestone becomes active.

## 4. Active sprint and task contract

The active milestone is the current sprint-level execution focus. It may require more than one time-boxed work cycle, but only the currently selected execution tasks are itemized in PROJECT_STATE.yaml.

Each active task must include:
- ID (T1, T2, ...), concise title, and status;
- exact target files or interfaces, distinguishing existing files from files to be created;
- contracts or questions to resolve, with stable contract IDs where useful;
- validation commands and expected evidence;
- dependencies and material assumptions.

Keep tasks independently reviewable and small enough to produce a verifiable outcome. Split a task when it mixes unrelated scientific contracts or has no coherent acceptance test. Do not encode performance budgets as hard pass/fail criteria unless the hardware, precision, workload, and measurement method are specified.

When a milestone closes:
1. Move its acceptance evidence into the milestone's closure record in the roadmap and/or a linked audit/R&D note.
2. Remove its active task list from PROJECT_STATE.yaml.
3. Reset task numbering for the next active milestone.
4. Preserve completed milestone IDs and evidence; do not preserve obsolete task IDs as a second backlog.

## 5. Lightweight Scrum-inspired operating model

- The **product backlog** is the ordered milestone roadmap. The project owner determines priorities and accepts scope changes.
- **Sprint planning** selects the active milestone goal and a small set of tasks with explicit acceptance criteria.
- The **sprint goal** is the milestone-level outcome, not a list of unrelated activities.
- **Execution review** checks task evidence, test results, blockers, and scope changes before tasks are marked complete.
- **Retrospective** records process changes only when they are likely to improve future work; do not create ceremony documents by default.
- The **Scrum Master function** is facilitation: keep the backlog coherent, expose dependencies and blockers, protect scope, and ensure evidence is recorded. It does not override the project owner's scientific or prioritization decisions.

For a solo workflow, these are responsibilities rather than mandatory separate human roles. Do not claim Scrum compliance merely because the terminology is used.

## 6. Change discipline and branch ownership

- Update the active task status and project-state record in the same commit as a material implementation, test, scope, or verification change on the milestone branch.
- Keep PROJECT_STATE.yaml and doc/MILESTONE_ROADMAP.md mutually consistent when a milestone opens, changes scope, or closes.
- Preserve unrelated user changes and do not report unrun local checks as passed.
- Do not copy an in-progress milestone state from one development branch to another. State and roadmap updates belong to the branch that owns that milestone until reviewed integration.
- Governance-policy changes belong on governance/project-governance; ordinary implementation and research milestones use their dedicated development branches and integrate through reviewed pull requests.

For multi-file state/roadmap updates, create one Git commit containing all related files. Inspect the branch head immediately before advancing its ref and use an expected-head check; do not split a logically atomic update into independent file commits.

## 7. Adaptive research roadmaps and cross-project dependencies

A roadmap is an **adaptive, evidence-responsive plan**, not a forecast of
scientific discovery. Its persistent phase/milestone hierarchy remains the
authoritative description of each repository's intended outcomes. Revise
priorities, dependencies, hypotheses to investigate, and milestone scope when
new results or obstructions justify doing so. Record the date, evidence or
observation, reason, affected milestone, and superseded plan; retain completed
history and do not retroactively claim that an earlier forecast was correct.

Repository boundaries are organizational, editorial, and historical choices.
Related projects may share literature, models, formalism, code interfaces, and
results while pursuing different questions. Each result has an **authoritative
source repository** and explicit provenance. A hub may maintain a cross-project
map, but must not duplicate or silently supersede child roadmaps, state files,
scientific contracts, or accepted results.

Issues communicate requests; they do **not** constitute a second milestone
hierarchy. Keep long-term objectives in the receiving project's roadmap and
active execution tasks in its project state. An exploratory Issue does not
automatically create a milestone or change current sprint priorities.

## 8. Cross-front and cross-repository requests

The interconnected fronts are defined by Rule 03: **(1) theory/research,
(2) laboratory/verification, and (3) scientific publishing**. They are
responsibilities, not independent teams, fixed directories, or one-way stages.

Use the smallest appropriate GitHub artifact:

- **Issue:** request a bounded deliverable, surface an uncertainty or
  discrepancy, or ask another repository for a scientific handoff.
- **Discussion:** explore an open-ended question before a deliverable is clear,
  if Discussions are enabled. Do not require Discussions for ordinary work.
- **Pull request:** propose a concrete change for independent review.
- **Milestone / Project board:** group an established collection of work; do
  not introduce these merely to mirror a few Issues.

A useful cross-project Issue answers, briefly:

1. **Why is the request needed?** Link the requesting project or result.
2. **What is required?** A scientific question, bounded artifact or decision.
3. **Who owns the work?** Identify the receiving repository, not necessarily
   an individual agent.
4. **What counts as evidence?** Expected source links, checks, limitations and
   a handoff; distinguish proof, numerics, interpretation and design review.
5. **What remains open?** Dependencies, assumptions and owner-reserved
   scientific decisions.

Do not prescribe the recipient's architecture, hypothesis, numerical
thresholds, or internal sprint unless an approved contract already does so.
One Issue may lead to a hypothesis, experiment, pull request, new request,
or a justified decision not to proceed. Record such pivots and cite links in
both directions when useful. Do not duplicate research records across
repositories merely to keep the board synchronized.

### Agent autonomy, review and closure

**Can:** An AI collaborator may autonomously create well-scoped Issues,
formulate candidate hypotheses, and pursue bounded research/implementation
work, including work it proposed, within the receiving repository's
authorization, risk gates, budgets, privacy policy, and branch discipline.
Creating an Issue does not grant broader repository privileges, funding,
deployment rights, or permission to edit frozen scientific contracts.

**Should:** Favor a small number of actionable requests tied to the current
research priorities; inspect existing work first. Work in isolated branches,
preserve project-specific governance, and publish concise provenance and
limitations rather than expansive speculative backlogs.

**Cannot:** The originating or implementing agent **cannot independently
certify its own Issue as solved**. A distinct reviewer (human or AI) may assess
the evidence, attempt falsification, and accept or reject a bounded deliverable,
subject to the scientific-risk and human-reserved decisions in Rules 08–09.
Independent review can authorize closure where repo policy and predeclared
criteria permit; this is **not** automatic merge, deployment, or blanket
scientific certification. Leave unresolved judgments open or conditionally
reviewed rather than reporting completion.

Not all work is binary: editorial, pedagogical and interface proposals may
be evaluated by explicit goals, comparisons, accessibility checks, and
documented reviewer judgment, not fictional true/false tests. Preserve
alternatives, dissent, and reversible decisions. The exact automation of
independent reviewer assignment/closure is a future implementation decision;
these paragraphs are behavioral policy, **not a claim of an implemented gate**.

## 9. Four distinct research planning records

Each adopting repository keeps four **separate** human-readable planning and research records, while preserving any existing machine-readable project state, scientific contract registry, and release CHANGELOG. Adoption requires a reviewed migration against the repository's existing naming and scope. Do not blindly rename historical files.

| Record | Default location | Single authority and permitted contents |
| --- | --- | --- |
| **Current sprint** | `CURRENT_SPRINT.md` | The bounded execution **brief**: goal, precise scientific assumptions, non-goals, deliverables, independent checks, blockers, next step, and links to the active task IDs. |
| **Adaptive roadmap** | `doc/MILESTONE_ROADMAP.md` or established `docs/MILESTONE_ROADMAP.md` (retain an existing `adaptative_roadmap.md` or `ROADMAP.md` until an explicit migration) | The **ordered milestone-level product backlog** defined in §§1–7, including the likely next 1–3 milestones and their readiness/dependencies, not a promised calendar or active task list. |
| **Idea backlog** | `BACKLOG.md` | A **non-committal incubation queue** of research questions, possible methods, alternatives, literature leads, and deferred ideas, with stable IDEA IDs, evidence qualifications and review triggers. It is distinct from Rule 05's milestone/product backlog. |
| **Research log** | `LOG_DISCOVERY_AND_PIVOTS.md` | The Rule 07 five-column index of dated observations, obstructions, failed approaches, and reasoned pivots; link to detailed research notes where the reasoning does not fit a concise row. |

The four records are **separate files even when the information flow is connected**. The file `CURRENT_SPRINT.md` does not replace `PROJECT_STATE.yaml`: where the latter exists, YAML alone owns the active task status, completed milestone evidence, and machine-checked state. The sprint brief must link to, not replicate, YAML tasks. A project without YAML may keep its already validated Lean/chapter workflow as active-task authority. Roadmap milestones and future sprint *candidates* do not implicitly authorize execution.

The idea backlog is not an Issue queue: opening a GitHub Issue is justified only for a bounded independently reviewable discrepancy, deliverable, or cross-project handoff. An idea is not a registered hypothesis, proof theorem, empirical fact, or acceptance threshold. Rule 08's immutable hypothesis/evidence protocol remains authoritative.

## 10. Idea triage, selection, and adaptive change

1. On intake, assign an owner-repository-scoped stable `IDEA-001`-style ID and record: question, why it matters, provenance, present evidence/limitations, first inexpensive test or falsifier, prerequisites, and any `TODO(owner)` choice. Status vocabulary: `inbox`, `investigating`, `deferred`, `promoted`, or `withdrawn`. These are **planning dispositions**, not scientific verdicts.
2. At a periodic planning review, retain, defer (with trigger), withdraw (with reason), or **propose** promotion to an approved roadmap milestone. Promotion requires the owner's priority decision; preserve the IDEA entry with a link, but transfer execution authority to the milestone/state files. No preallocated T1/T2 IDs for future ideas.
3. Select only a bounded subset of the current milestone's work for the sprint brief, using current `PROJECT_STATE.yaml` when present. Require a scientific definition, domain, non-goals, evidence oracle, blockers, and stop conditions. Do not imply a CI pass proves a mathematical conjecture.
4. Re-plan the roadmap when new evidence changes dependencies, feasibility, or objectives. Record dated reason and supersession link in the research log or an R&D note; do not erase the original plan or silently rewrite accepted hypothesis statements.
5. A long-term item can remain only in `BACKLOG.md` without an Issue or planned milestone. Conversely, completed milestone history stays in the owning roadmap/state; do not move it into the idea backlog.

Existing one-file backlogs must be migrated **losslessly**: first establish an item-to-destination ledger, then copy/classify without deleting or silently rewriting numerical assumptions. Mark the former file as a dated source snapshot and link the new destinations; remove the legacy duplicate only in a separate, reviewed cleanup. Reconcile branch- and milestone-specific conflicts before promoting statuses.

## 11. Automation and review boundaries

A deterministic, dependency-light helper may check presence/structure, IDEA ID uniqueness, roadmap and sprint links, and the Rule 07 table header. It may **draft** new IDEA or research-log entries but must not invent research observations, commit/push without an explicit command, modify frozen contracts, select an active sprint, or announce an independent scientific verdict. Never silently rewrite historical log entries to satisfy a new parser.

Use `python3 scripts/planning_records.py` in this repository as a reference tool for the adopted Markdown format; invoking it against another repository is opt-in. The helper's explicit `log-entry --apply` may insert a user-supplied five-column entry, but the investigator/reviewer must author and check its physical interpretation. When a change materially affects the active milestone, scientific assumptions, or next actions, obey Rule 06's **same-commit** state/roadmap/evidence discipline. A generic validation check is not a substitute for a project's existing `make verify`, Lean locks, scientific review, or owner's threshold decision.

## PG-10 compatibility

[PG-10](10_atomic_unit_of_work.md) adds lawful transition and repository-first
resumption obligations. Native records retain authority; structured events require
separate adoption. The reference toolkit reports mechanical findings, not scientific
acceptance. No child migration or universal file renaming follows from this rule.
