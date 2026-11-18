---
name: project-navigator
description: >-
  Navigate project directory structure, Git branch topology, past-present-future chronology,
  and hypothesis derivation provenance across active repositories using deterministic orchestrator tools.
---

# Project Navigator Skill

Use this skill whenever the user asks about:
- **Project Status & Health:** Current active phase, milestone in progress, active tasks, uncommitted diffs, and stream worktrees across `kitaev-mf`, `kitaev-walk-geometry`, `ksl-sc-bilayer`, or other workspace projects.
- **Git Branch Topology & Chronology:** "What happened on branch X vs Y?", "What is the past history?", or "What are our projected future options / roadmap backlog?".
- **Hypothesis Provenance:** "How did we reach hypothesis Y / invariant K-xxx?", "What was the derivation chain?", or "Why did the naive approach fail?".
- **Quantitative Queries:** Looking up exact mathematical equations, numerical condition numbers, tolerances, critical fields, or benchmark tables.

---

## 1. Operating Procedure (Deterministic First)

Never guess or hallucinate project state, milestone IDs, or equations. Always execute the deterministic orchestrator tools first:

```bash
# 1. Inspect project status & active sprint tasks:
PYTHONPATH=orchestrator python3 -m agentctl project <PROJECT_NAME> status
# (Or Makefile shortcut: make proj-status PROJ=<PROJECT_NAME>)

# 2. Inspect past-present-future chronology:
PYTHONPATH=orchestrator python3 -m agentctl project <PROJECT_NAME> timeline [--format text|json|mermaid]
# (Or Makefile shortcut: make proj-timeline PROJ=<PROJECT_NAME>)

# 3. Trace hypothesis provenance & derivation slice:
PYTHONPATH=orchestrator python3 -m agentctl project <PROJECT_NAME> hypothesis --id <ID> [--explain]
# (Or Makefile shortcut: make proj-why PROJ=<PROJECT_NAME> H=<ID> [EXPLAIN=1])

# 4. Search metadata, R&D notes, and labbooks:
PYTHONPATH=orchestrator python3 -m agentctl project <PROJECT_NAME> query --query "<KEYWORDS>"
# (Or Makefile shortcut: make proj-query PROJ=<PROJECT_NAME> Q="<KEYWORDS>")
```

---

## 2. Response Formatting Rules

When presenting results to the user:

1. **Clickable Links First:**
   Always provide direct, single-click Markdown links (`[File](file:///absolute/path)`) to:
   - The compiled PDF (`doc/labbook/*.pdf` or `doc/manuscript/*.pdf`),
   - The primary R&D note (`doc/rnd/...md`),
   - The LaTeX chapter source (`doc/labbook/chapters/*.tex`),
   - The benchmark data table (`data/processed/benchmarks/*.dat`).

2. **Dichotomy of Discovery vs. Justification:**
   Structure hypothesis explanations clearly:
   - **Context of Discovery (Front 1):** The initial guiding questions, dependencies, and dead ends / pivots recorded in `LOG_DISCOVERY_AND_PIVOTS.md`.
   - **Context of Justification (Front 2/3):** The rigorous mathematical formulation, exact equation, proof/invariance gate, and compiled labbook/manuscript section.
   - **Empirical Evidence:** Benchmark `.dat` files, bootstrap / Wilson score confidence intervals, and test targets.

3. **Compact & Model-Agnostic:**
   Keep answers concise and structured in logical bullet points ($A \implies B \implies C$) suitable for the researcher's cognitive assimilation.
