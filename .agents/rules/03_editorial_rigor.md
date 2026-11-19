---
trigger: model_decision
description: Three-Front R&D architecture (doc/rnd, doc/labbook, doc/manuscript), citation verification, and claim rigor.
---
<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 03: Three-Front R&D Architecture, Editorial Rigor, and Provenance

Apply these standards to research notes, living labbooks, architecture records, code documentation, and publication-facing manuscripts.

## Governing principle — three interconnected fronts

The three fronts name **accountabilities and deliverables**, not mutually exclusive
epistemic stages, job titles, or disjoint sets of repositories.

- **Front 1 — Theory and research:** formulate questions, review literature,
  identify assumptions, derive relations, propose hypotheses, and state possible
  falsification or proof strategies.
- **Front 2 — Laboratory and verification:** carry out analytical and numerical
  experiments, implement methods, test claims, report discrepancies, and record
  independently inspectable evidence.
- **Front 3 — Scientific publishing:** construct self-contained explanations,
  figures, educational demonstrations, manuscripts, and other public deliverables
  whose claims and provenance can be evaluated by readers.

**There is no strict boundary between the contexts of discovery and
justification.** Exposition can expose an unrecognized assumption; a failed
numerical experiment can revise a hypothesis; and a proof can change which
experiment ought to be performed. Work may move **in either direction** between
the fronts. Publication is not an infallible endpoint, and laboratory agreement
does not automatically justify an underlying physical approximation.

One person, agent, file, or repository may contribute to several fronts.
Assign ownership to a **bounded deliverable**, not permanently to a person,
scientific topic, language, or directory. The division of a broad research
program into projects is partly an organizational, editorial, and historical
choice: related repositories may share theory and literature while retaining
distinct objectives and their own authoritative records.

Cross-front and cross-repository requests should name the needed result,
its owner, assumptions, evidence standard, source links, and outstanding
decisions. An Issue can request a handoff; a reviewed PR integrates an artifact.
Neither an Issue nor an automated check certifies a scientific result by itself.
Preserve independent review, explicit uncertainty, provenance, and the owner's
authority over hypotheses and scientific acceptance criteria.

Roadmaps are **adaptive plans**, not predictions of discovery. Update priorities,
milestones, and dependencies as evidence changes while preserving decisions and
the rationale for changes; Rule 05 governs the concrete milestone/task lifecycle.

## 1. The Three-Front R&D Document Architecture

Scientific software and theoretical physics repositories may organize documentation
around the three fronts using the artifact-specific conventions below. This table
describes **documentary emphasis**, not a rigid workflow or epistemic partition:

| Front | Canonical Path | Epistemic Role | Audience & Format |
| :--- | :--- | :--- | :--- |
| **Front 1: Agentic R&D Front** | `doc/rnd/phase_<N>/` & `doc/rnd/exploratory/` | **Context of Discovery:** Derivations, conventions, idealization boundaries, algorithmic edge cases, numerical experiments, and failed approaches. | Machine- and developer-first Markdown (`m<P>_<M>_t<T>_<slug>.md`) with mandatory YAML frontmatter, paired with `LOG_DISCOVERY_AND_PIVOTS.md`. |
| **Front 2: Living Lab Book** | `doc/labbook/` | **Context of Justification:** Cumulative pedagogical synthesis integrating the motivating questions and dead ends from Front 1 with complete derivations, verified invariants, and reproducible `.dat` plots. | Human-first `memoir` LaTeX book (`doc/labbook/main.tex`) using the shared warm parchment theme (`#FAF6EE` background, `#2B2B2B` text) and `pgfplotstable`. |
| **Front 3: Publication Manuscript** | `doc/manuscript/` (or `doc/report/`) | **Context of Exposition:** Self-contained journal paper or monograph narrative stripped of internal project scaffolding. | External referees and readers (`revtex4-2`, `article`, or `memoir` with white print toggle `\warmthemefalse`). Must never depend on unpublished `doc/rnd/` scratch notes. |

The traditional labels *context of discovery*, *context of justification*,
and *context of exposition* describe the usual emphasis of these documents.
They are not exclusive philosophical categories. In particular, Front 2 also
includes source code, calculation notebooks, test suites, and raw experimental
records outside `doc/labbook/`; Front 3 can be a website note or other
standalone published artifact outside `doc/manuscript/`.

### 1.1 Front 1 (`doc/rnd/`) YAML Frontmatter Contract

Every milestone-indexed R&D note (`doc/rnd/phase_<P>/m<P>_<M>_t<T>_<slug>.md`) must begin with structured YAML frontmatter so `make_snapshot.py` and `build_blueprint.py` can index the epistemic graph:

```yaml
---
id: RND-P1-M1.1-T1
title: "Finite-Lattice Conventions and Local Majorana Algebra"
phase: 1
milestone: M1.1
task: T1
status: completed # draft | active | blocked | completed | pivoted
questions:
  - "What local Majorana representation and parity projection uniquely fix the spin-1/2 algebra?"
depends_on: []
contracts:
  - A01
  - A02
claims:
  - K-001
  - K-002
artifacts:
  - src/pkg/domain/algebra.py
  - test/unit/test_algebra.py
---
```

### 1.2 Mandatory LaTeX Provenance & Editorial Comments (Fronts 2 & 3)

Every chapter and section in `doc/labbook/` and `doc/manuscript/` must obey three source-comment contracts:

1. **Guiding Question (`% EDITORIAL QUESTION:`):**
   - Place `% EDITORIAL QUESTION: <concise physical or mathematical question>` immediately before every numbered `\section` (and any `\subsection` addressing an independent question).
   - Lead with the physical observable or concrete motivating example before introducing abstract apparatus.
   - Explicitly answer the guiding question in the section's scientific conclusion.
2. **External Reference Locators (`% SOURCE [STATUS]:`):**
   - Every nonstandard or externally sourced formula/theorem requires a comment:
     `% SOURCE [VERIFIED|UNVERIFIED]: <Author (Year), Edition, Ch/Sec/Eq locator — supported claim>`
   - Never fabricate page numbers, equation numbers, or locators.
3. **Internal Claim Traceability (`% CLAIM:`):**
   - When promoting a verified project result into `doc/labbook/` or `doc/manuscript/`, annotate its provenance:
     `% CLAIM: <ID> (note: doc/rnd/..., test: test/..., data: data/processed/benchmarks/...)`

## 2. Mathematical claims, idealizations, and provenance

1. State definitions, domains, idealizations (mean-field, finite-size cluster, perturbative order, gauge sector, regulator), and boundary conditions before relying on them.
2. Give proofs for nontrivial claims when presenting them as established results. Identify omitted arguments and cite a verifiable source when relying on an external result.
3. Strictly distinguish:
   - exact algebraic identities and analytical theorems;
   - finite-volume or finite-dimensional exact results;
   - floating-point numerical benchmarks and convergence tests;
   - approximations, extrapolations, and conjectures.
4. Do not promote finite-size numerical agreement into a thermodynamic claim without a controlled limiting argument. A passing test certifies only its tested computational contract and parameter domain.
5. Record limiting-case checks and independent validations when they materially support the result. Explain what those checks do and do not establish.

## 3. Conventions and mathematical typography

State conventions explicitly whenever they affect signs, prefactors, symmetry representations, or physical interpretation:
- lattice graph, sublattice, and bond orientation;
- Fourier-transform and Brillouin-zone normalization;
- operator/parton representation, normal ordering, and physical-state projection;
- index ranges, summation conventions, and matrix ordering;
- boundary conditions and finite-size geometry.

Typographical standards across Markdown and LaTeX:
- Use upright Roman type for named operators and labels (`\Tr`, `\tr`, `\Pf`, `\sgn`, `\diag`, `\mathrm{d}k`, `\mathrm{MF}`, `\mathrm{BdG}`, `\mathrm{BZ}`).
- Use blackboard bold for number fields and identity operators (`\mathbb{R}`, `\mathbb{C}`, `\mathbb{Z}_2`, `\mathbb{1}`).
- Use `\DeclarePairedDelimiter{\abs}{\lvert}{\rvert}` and `\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}` for properly scaled delimiters.
- Punctuate displayed equations as part of the surrounding prose sentence.

## 4. Code and mathematical notation

1. Use descriptive English identifiers by default. Conventional uppercase names for matrices, Hamiltonians, exchange tensors, and operator representations are acceptable when they improve correspondence with the mathematical notation.
2. Maintain strict architectural separation:
   - `domain/`: pure mathematical entities, parameters, lattices, and port interfaces;
   - `services/`: physics and numerical algorithms depending only on domain abstractions;
   - `infra/`: hardware backends (CPU/CUDA), file I/O, and `.dat` tabular exporters;
   - `app/`: CLI entrypoints and workflow orchestration.
3. Avoid semicolon-compressed statements and minified code. Preserve readability and explicit control flow.

## 5. References and bibliographic integrity

1. Cite primary literature, peer-reviewed work, authoritative books, and original software documentation as appropriate to the claim.
2. Verify bibliographic metadata against publisher records, DOI registries, arXiv records, or the cited source itself. Never invent or infer a DOI, arXiv identifier, title, author list, page range, or publication year.
3. Use a consistent citation style appropriate to the document. Author-year citations are suitable for Markdown research notes (`doc/rnd/`); use BibTeX (`refs.bib`) and the target venue style for `doc/labbook/` and `doc/manuscript/`.
