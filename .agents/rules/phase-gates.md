# Phase Gates

## Gate 1 — BasisAndAlgebra

Required:

- CAR tests pass;
- projector tests pass;
- independent physics audit passes;
- no forbidden symbolic machinery introduced.

## Gate 2 — Single-Site / Kanamori

Required:

- SOC oracle passes;
- d^4 multiplet energy oracle passes;
- P_[L=0], P_[L=1], P_[L=2] semantics are verified;
- independent physics audit passes.

## Gate 3 — Schrieffer-Wolff

Required:

- state-action strategy verified;
- no uncontrolled global operator expansion;
- physical limiting tests pass;
- complexity audit passes.

## Gate 4 — Exchange Extraction

Required:

- Pauli traces validated;
- J_H = 0 limits validated;
- lambda_SOC = 0 limit validated;
- point-group symmetry validated;
- independent physics audit passes.

## Gate 5 — Formal Verification

Required:

- proof certificate generated;
- Lean accepts the relevant certificate;
- no unsupported axiom has been inserted solely to force success.
