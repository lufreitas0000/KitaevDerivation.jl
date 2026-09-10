---
name: symbolic-physics
description: Provides constrained symbolic-physics methods for fermionic CAR, projector algebras, Kanamori multiplets, SOC, Schrieffer-Wolff reduction, and exchange extraction.
---

# Symbolic Physics Skill

## Canonical CAS

Use:

    Symbolics.jl
    SymbolicUtils.jl

Avoid mixing symbolic AST ecosystems.

## Canonical multiplet projectors

Use exactly:

    P_[L=0]
    P_[L=1]
    P_[L=2]

These denote orbital-angular-momentum multiplet projectors.

Never confuse them with low-energy projectors such as:

    P_low
    P_hole
    P_half

## Kanamori energies

    DeltaE_[L=0] = U + 2*J_H
    DeltaE_[L=1] = U - 3*J_H
    DeltaE_[L=2] = U - J_H

## d^4 strategy

Treat the 15-state manifold abstractly through symmetry/projector sectors.

Do not perform generic symbolic dense diagonalization.

## Schrieffer-Wolff strategy

Always prefer:

    operator/state action from right to left
    ->
    CAR normalization
    ->
    normal ordering
    ->
    immediate projection
    ->
    simplify
    ->
    accumulate

This is the primary complexity-control mechanism.

## Sign conventions

Never silently change:

- hole/particle conventions;
- hopping signs;
- SOC signs;
- Pauli conventions;
- bond-axis conventions;
- basis phases.

Document every convention.

## Symbolic output

Keep symbolic expressions compact.

Do not print giant ASTs.
