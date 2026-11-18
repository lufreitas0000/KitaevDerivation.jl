<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 02: Testing and Numerical Verification

## 1. Test-driven development

1. For a new mathematical entity or physics algorithm, define its contract before implementation: inputs and domains, assumptions, conventions, expected invariances, limiting cases, and failure behavior.
2. Add focused tests for the contract. Use a red-green-refactor cycle where practical: demonstrate that a new regression test detects the defect or missing behavior before relying on it to validate the implementation.
3. Prefer tests of independent identities and limiting cases over tests that merely duplicate the implementation's internal steps.
4. Keep pure mathematical logic independently testable. Isolate backend, filesystem, and other side effects behind explicit interfaces.
5. Refactor only while preserving the tested contract. Follow the configured Ruff and strict Mypy checks.

## 2. Numerical tolerances

There is no universal absolute tolerance for all algebraic, spectral, or numerical tests. Choose acceptance criteria according to:

- the scale and units of the compared quantities;
- floating-point precision and the operations performed;
- conditioning of the problem and sensitivity to input perturbations;
- algorithmic error, convergence criteria, and expected residual;
- whether the test concerns an exact identity, a discretization, or an approximate physical result.

Use absolute tolerances when the expected quantity can be near zero, relative tolerances when scale variation matters, and both when appropriate. State the rationale for unusually tight or loose tolerances. Do not loosen a tolerance merely to make a test pass.

For exact symbolic or integer-algebraic identities, prefer exact comparisons. For floating-point calculations, a tolerance is a numerical acceptance criterion, not a proof of the identity.

## 3. Physics verification

Use the following checks when applicable to the mathematical object and convention being implemented:

- matrix Hermiticity or skew-symmetry, as appropriate;
- trace orthogonality and Lie-algebra commutators for generator representations;
- symmetry constraints and expected degeneracies;
- analytically controlled limits, including the pure-Kitaev limit where the relevant Hamiltonian and representation reduce to it;
- Brillouin-zone periodicity and supercell folding when constructing momentum-space Hamiltonians;
- independent finite-volume or alternative-representation checks when feasible.

The pure-Kitaev dispersion and flat-band benchmarks recorded in the project R&D notes are project-specific contracts. Before applying them, verify that the Hamiltonian normalization, Majorana convention, bond orientation, unit cell, and Fourier convention match the implementation under test. Do not transplant a prefactor or flat-band expression across conventions by inspection.

## 4. Tooling and reported verification

The root `pyproject.toml` defines the Python package metadata and Ruff, Mypy, and pytest configuration. The Makefile and CI workflow define concrete command sequences; inspect them rather than assuming that local and remote checks are identical.

- Run focused tests during development and the relevant broader suite before integration.
- Run Ruff lint and format checks and strict Mypy on the affected source/test scope.
- Include scripts in local checks when they are changed; the current CI workflow checks `src/` and `test/`, whereas the Makefile also includes `scripts/`.
- Report exact commands and outcomes. Distinguish passed, failed, skipped, and not-run checks.
- A passing finite test establishes only the tested property and parameter domain. It does not prove a general analytical or thermodynamic statement.
