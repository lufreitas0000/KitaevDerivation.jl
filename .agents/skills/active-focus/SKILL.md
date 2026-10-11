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

1. **Priority 1 (Deep Work — Primary Sprint):**
   * Currently: `xxz-multimethod-benchmark` Milestone 1 (Exact Diagonalization in Lean 4 & Julia) and `Lean/finite-QMB` (Hal Tasaki CAR algebra & Perron-Frobenius).
   * All primary engineering energy belongs here.

2. **Parallel Track (Foundations & Learning):**
   * Currently: `Lean/learning_lean/` (Category Theory in Lean 4 via Milewski CTFP + Mathlib foundational exercises).
   * Progress is measured by demonstrated capability (Kanban: Backlog $\to$ Ready $\to$ In Progress $\to$ Review $\to$ Done).

3. **Background Track (Corpus Transcriptions & Jules Verification):**
   * Google Colab batch OCR (`references-transcripts`) and Jules background verification.
   * Autonomous / asynchronous; does not consume primary interactive agent turns unless explicitly asked.

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
| Date | Context / Target Lemma | Obstruction / Bottleneck | Resolution / Architectural Pivot |
| :---: | :---: | :--- | :--- |
| YYYY-MM-DD | [Module / Lemma] | [Specific obstruction encountered] | [Concrete resolution or pivot taken] |
```

---

## 4. Updating Sprint State in `ACTIVE_FOCUS.md`

When a milestone sub-task completes:
1. Ensure the code compiles (`lake build` for Lean, `julia --project -e 'using Pkg; Pkg.test()'`).
2. Verify git cleanliness (`git status` clean, commit pushed to `origin`).
3. Update the corresponding checkbox or Kanban status in `/home/lucas/Projects/ACTIVE_FOCUS.md`.
