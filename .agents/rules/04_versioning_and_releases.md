<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 04: Versioning, Changelog, and Releases

This rule governs releases of the installable `kitaev-mf` Python package. It does not version research milestones, R&D notes, benchmark identifiers, or persistent scientific claim IDs.

## 1. Single source of truth

- The package version is declared by `[project].version` in the root `pyproject.toml`.
- Do not maintain a second manually edited version file. If version metadata is later generated dynamically, update this rule and the release workflow in the same change.
- The version in `pyproject.toml`, the release tag, and the GitHub release must agree exactly.
- Use tags of the form `vX.Y.Z`, for example `v0.2.0`.

## 2. Semantic Versioning

Use the three-part form `MAJOR.MINOR.PATCH`.

### Before 1.0.0

The public API is not yet stable. Use the following practical policy:

- Increment `0.MINOR.0` for a new public capability, a public API change, or a breaking change. Reset PATCH to zero.
- Increment `0.MINOR.PATCH` for backward-compatible bug fixes, documentation-only corrections, and internal changes that do not alter the public API.
- Do not use a patch release to conceal a breaking public API change.

This deliberately treats the MINOR component as the compatibility boundary while the major version is zero.

### From 1.0.0 onward

Apply SemVer 2.0.0:

- **PATCH** (`X.Y.Z+1`): backward-compatible bug fixes and internal changes.
- **MINOR** (`X.Y+1.0`): backward-compatible public functionality; reset PATCH to zero.
- **MAJOR** (`X+1.0.0`): incompatible public API changes; reset MINOR and PATCH to zero.

The public API includes documented import paths, public classes/functions, supported configuration keys, and documented command-line interfaces. Internal modules are not public merely because they exist in the source tree; document any supported extension points explicitly.

## 3. Changelog

- Maintain `CHANGELOG.md` using a concise Keep a Changelog-style structure.
- Put unreleased work under `## [Unreleased]`, grouped where useful into Added, Changed, Fixed, Deprecated, Removed, and Security.
- Every release gets a dated `## [X.Y.Z] - YYYY-MM-DD` section.
- Describe user-visible behavior and compatibility impact. Do not use the changelog as a commit log.
- Update the changelog in the same pull request as the change it records. Move relevant Unreleased entries into the versioned section when preparing a release.
- Do not label a version as released until its matching Git tag and GitHub release exist.

## 4. Release procedure

1. Confirm the target version from the accumulated changes and compatibility impact.
2. Update `pyproject.toml` and `CHANGELOG.md` in a dedicated release PR.
3. Run the complete CI workflow and review the generated package metadata/build artifact.
4. Merge the release PR to `main`.
5. Create an annotated Git tag `vX.Y.Z` at the release commit and publish the matching GitHub release with the changelog notes.
6. Verify that the tag points to the intended commit and that the published package metadata reports the same version.

Never create or move a release tag to repair a version mismatch. Correct the source and issue a new version instead.

## 5. Pre-releases and research work

- Use SemVer pre-release identifiers only for explicitly distributed candidate builds, e.g. `0.2.0rc1` or `1.0.0-beta.1`; do not tag ordinary research commits.
- Research branch names, milestone labels, note numbers, and claim IDs are not package versions.
- Do not bump the package version for every commit, CI repair, documentation edit, or internal research milestone.
- Only release from `main`. A research branch may update versioning documentation, but it must not publish or tag a package release.

## 6. Pull-request checklist

Before merging a change that affects release metadata:

- [ ] Is the change user-visible or public-API relevant?
- [ ] Is the version bump appropriate for the current pre-1.0 or stable policy?
- [ ] Is `CHANGELOG.md` updated?
- [ ] Does `pyproject.toml` contain the intended version?
- [ ] Will the release tag and GitHub release use exactly that version?
- [ ] Has CI passed on the proposed merge commit?
