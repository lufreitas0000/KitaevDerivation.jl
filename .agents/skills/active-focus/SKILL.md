---
name: active-focus
description: >-
  Inspect, align with, and update the active sprint state across the workspace.
  Enforces the "Rule of 3" (Priority 1 deep work, parallel foundations track, background track),
  checks workspace health (proj-status / proj-diff / proj-summary), and journals proof/algorithmic
  obstructions in LOG_DISCOVERY_AND_PIVOTS.md.
---

# Active Focus & Sprint Governance Skill

This skill governs workspace-wide focus alignment, preventing context drift across multiple simultaneous theoretical physics, formal verification, and numerical modeling projects.

---

## 1. The "Rule of 3" & Sprint Alignment

Before proposing or executing code or proof tasks, always read `/home/lucas/Projects/ACTIVE_FOCUS.md`.

Work is strictly partitioned into three concurrent tracks:

1. **Priority 1:** Read the current cockpit. As of October 13, 2026, the
   Web-LLM pipeline is primary; XXZ, bosonize-lean and finite-QMB implementation
   waits until pipeline readiness or explicit user reprioritization.
2. **Parallel:** Bounded `Lean/learning_lean/` category theory and Mathlib study.
3. **Background:** Existing reference transcription/review activity. Do not
   initiate unrelated jobs while completing the pipeline.

> [!IMPORTANT]
> **Icebox Guard:** Any repository or task listed under **Icebox / Standby** in `ACTIVE_FOCUS.md` (e.g., `climbing/`, `nexus/`, `islp/`, `archive/`) must NOT be worked on without explicit, direct user instruction.

---

## 2. Workspace Health & Activity Inspection

Any agent beginning a session or major sprint milestone should run:

```bash
# 1. Quick parallel health check
python3 /home/lucas/Projects/status.py

# 2. Check uncommitted diffs or last commit diffstat
python3 /home/lucas/Projects/status.py --diff

# 3. Check recent commits across active repositories
python3 /home/lucas/Projects/status.py --recent 3

# 4. Check recent mathematical & architectural pivot entries
python3 /home/lucas/Projects/status.py --pivots
```
*(Or the bash aliases: `proj-status`, `proj-diff`, `proj-recent`, `proj-pivots`, `proj-summary`).*

---

## 3. Failure & Discovery Journaling Protocol

Whenever an agent encounters:
- A tactic failure or Lean 4 elaboration bottleneck,
- An unprovable theorem statement requiring modified hypotheses,
- A Julia performance bottleneck or CAS expression blowup,
- A branch divergence or merge conflict across AI agents,

The agent **MUST** log the event in the project's `LOG_DISCOVERY_AND_PIVOTS.md` before changing definitions or pivoting code:

```markdown
| Date | Module/Context | Obstruction | Pivot/Resolution | Status |
| --- | --- | --- | --- | --- |
| YYYY-MM-DD | [Module / Lemma] | [Specific obstruction] | [Resolution] | [Status] |
```

---

## 4. Updating Sprint State in `ACTIVE_FOCUS.md`

When a milestone sub-task completes:
1. Ensure the code compiles (`lake build` for Lean, `julia --project -e 'using Pkg; Pkg.test()'`).
2. Verify git cleanliness (`git status` clean, commit pushed to `origin`).
3. Update the corresponding checkbox or Kanban status in `/home/lucas/Projects/ACTIVE_FOCUS.md`.
