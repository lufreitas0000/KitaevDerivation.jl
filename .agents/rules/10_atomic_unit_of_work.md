<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# PG-10: Atomic Units of Work and Repository-First Governance

**Version:** PG-10/1. **Scope:** common contract plus opt-in reference tooling.
The owner approved D0–D1 implementation on 2026-11-15. This does not activate
new records, priorities or governance profiles in child repositories. Local
rules with number 10 retain their identifiers and authority.

## Contract

A Unit of Work (UoW) is the smallest independently reviewable transition with
one bounded objective, normally one coherent Git commit. Tasks can span UoWs.
For policy/profile P, require both valid endpoints and a lawful transition:

`I_P(S_before) AND T_P(S_before, Delta, evidence, authority, S_after) AND I_P(S_after)`.

A state identifies repository, candidate bytes, applicable authorities and
policy versions. HEAD alone does not identify index or worktree content.
Validity means truthful, consistent and resumable; unresolved research and
failed tests may be valid recorded outcomes. An investigation checkpoint does
not thereby complete a proof or satisfy a production integration gate.

## Obligations

State invariants: unambiguous authority; valid structure and references;
truthful status/evidence; preservation; recoverable goal/next action or blocker;
separation of checkpoint, publication, review, acceptance, integration/release.

Transition obligations: expected base; bounded writable scope; applicable
existing authorization; candidate-bound evidence; historical continuity;
explicit concurrency conflicts; recovery/compensation appropriate to effects.
Two parseable snapshots do not establish that their transition was lawful.

Machine findings use pass/fail/unknown and explicit blocking scope. They do
not prove scientific truth, authenticate actor declarations or provide
independent acceptance. Keep Rules 08–09, existing delegation and owner-reserved
decisions. No extra confirmation is needed for each step already authorized.

## Operating procedure

Inspect the correct branch, index/worktree and native authorities; declare the
bounded objective, base, scope, checks and authorization; execute; record actual
checks and unresolved findings; reconcile affected native state and evidence;
checkpoint coherently under Rule 06. Publish/review/integrate only under the
applicable authority. No UoW requires every planning file to change.

Read-only tooling must not generate bytecode/caches, refresh the index, contact
remotes implicitly, execute hooks or run commands supplied by project records.
An exit code for successful observation is not scientific acceptance.

A local checkpoint, verified remote publication, independent scoped review,
acceptance, integration and release are separate axes. Git is neither a semantic
verifier nor a distributed transaction across sibling repositories. A hub
summary names observed child revisions and freshness, without owning their science.

## Storage and recovery

Compatibility mode preserves established state, roadmap, sprint, journal,
changelog and scientific records. Each fact has one authority. Event sourcing
is optional and requires separate reviewed adoption; authored reasoning stays
authored. Do not generate scientific conclusions from diffs. Preserve established
Horizon/roadmap paths and local workflow vocabularies; see the glossary.

Reversibility means an evidenced forward compensation where appropriate, not
history deletion. Code can be undone in a new commit; interpretations can be
superseded with links. Some external effects cannot be reversed. Existing
operational authorization gates still apply. No ordinary reversal may delete
accepted immutable scientific/event history. Security redaction is a separate
Rule 01 procedure.

## Reference and boundaries

[Operational toolkit](../governance/README.md), [glossary](../docs/pg10/GLOSSARY.md),
and [approved plan](../docs/PG10_IMPLEMENTATION_PLAN_PROPOSED.md).
D0–D1 is the initial minimal delivery. Compatibility expansion, event persistence,
Git mutation tooling, hub aggregation and fleet migration are later decisions.
The global toolkit is not a required directory layout or runtime dependency
for every child. Adoption must preserve existing accepted scientific thresholds.

## Central implementation availability — 2026-11-15

The owner subsequently authorized central completion beyond the original D0–D1
boundary. [Current workflow](../docs/pg10/CENTRAL_WORKFLOW.md) specifies native-v2
compatibility, optional immutable observation/UoW bundles, reproducible distribution,
staged Git checkpoints, separate publication and hub integration. Native scientific
records and reserved acceptance remain authoritative. Event adoption is explicit
per information kind; full fleet migration is a separate sequence of local UoWs.
The contract remains universal while these storage mechanisms are optional.
