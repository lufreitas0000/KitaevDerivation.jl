<!-- @CANONICAL-RULE: DO NOT EDIT DIRECTLY. MANAGED BY project-governance -->
# Rule 08: Living Hypothesis Contracts, Scientific Falsification & ACID Provenance

## 1. Living Hypothesis Contract (HC) Lifecycle

Every physical conjecture, asymptotic scaling law, phase boundary claim, or formal theorem target across projects must be governed by a structured YAML Hypothesis Contract in `doc/hypotheses/HC-XX.yaml` (compiled into `doc/HYPOTHESIS_CONTRACTS.md` or the project blueprint portal).

1. **Pre-Registration & Threshold Ownership:**
   - Quantitative falsification and verification thresholds (`support_if` and `refute_if`) are owned exclusively by the human Principal Investigator (`TODO(owner)` until formally locked).
   - Autonomous agents must **never** invent or relax numerical thresholds or mathematical hypotheses to force an artificial pass.
   - Refutation is a first-class scientific discovery, not a test failure. When a hypothesis is refuted, the contract status transitions to `refuted`, and the mechanism must be documented in `LOG_DISCOVERY_AND_PIVOTS.md`.

2. **Living Evolution (`learning_log` & `spawned_hypotheses`):**
   - As analytical derivations, formal proof attempts, or numerical sweeps uncover new constraints, selection rules, or parameter bounds, record dated, commit-stamped observations in `learning_log`.
   - When an existing hypothesis splits into distinct parameter regimes or inspires a daughter conjecture, spawn a linked child contract referencing the parent (`from: HC-XX`).

3. **Anti-Vacuity & Non-Degeneracy Gates (F1 / F2):**
   - **F1 (Wrong Statement Gate):** Independent specification check before proof/computation begins.
   - **F2 (Vacuous Proof Gate):** Mandatory explicit non-degeneracy witnesses, solvable limiting cases, or non-trivial carrier representations to prevent tautological vacuities.

---

## 2. ACID Data & Benchmark Provenance

All benchmark tables, simulation data, and numerical spectra (`data/processed/benchmarks/*.dat`, `*.csv`) must enforce ACID reliability:

1. **Atomicity:**
   - Data and companion metadata manifests (`<name>.dat` and `<name>.meta.json`) must be written via atomic temporary file replacement (`tempfile.NamedTemporaryFile` + `os.replace`), certified only after all invariant checks pass.
2. **Consistency (Invariant Gates):**
   - Before committing any benchmark table, the generation pipeline must verify all fundamental algebraic and physical invariants (e.g. Hermiticity, particle-hole/time-reversal symmetry, spectral sum rules, total probability / trace conservation).
3. **Isolation (Multi-Agent & Multi-Stream Concurrency):**
   - Concurrently executing agents must operate on stream-sharded state manifests (`state_shard.yaml` or task-unique seeds) to prevent concurrent write collisions on shared benchmark files.
4. **Durability & Traceability (# Header Contract):**
   - Every tabular export must include a standardized, machine-parseable `#` provenance header:
     ```text
     # generator_script: {{GENERATOR_SCRIPT}}
     # git_sha: {{GIT_SHA}}
     # git_dirty: false
     # config_sha256: {{CONFIG_SHA256}}
     # timestamp: {{TIMESTAMP}}
     # rng_seed: {{RNG_SEED}}
     # parameters: {{PARAMETERS_JSON}}
     ```
