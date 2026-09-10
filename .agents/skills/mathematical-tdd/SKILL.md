---
name: mathematical-tdd
description: Generates and evaluates independent mathematical-physics tests based on identities, symmetry, physical limits, analytical results, and computational invariants.
---

# Mathematical Physics TDD

Software tests alone are insufficient.

Every important module should have tests belonging to one or more classes:

    ALGEBRAIC
    PROJECTOR
    PHYSICAL_ORACLE
    LIMIT
    SYMMETRY
    REGRESSION
    NUMERICAL_CROSSCHECK
    COMPLEXITY

## Core algebra

CAR:

    {c_a,c_b†} = delta_ab
    {c_a,c_b} = 0
    {c_a†,c_b†} = 0

## Projectors

For any physical projector:

    P^2 = P

For mutually exclusive sectors:

    P_i P_j = 0

Completeness must follow from the explicit decomposition being tested.

## Multiplets

Canonical notation:

    P_[L=0]
    P_[L=1]
    P_[L=2]

Expected energies:

    U + 2*J_H
    U - 3*J_H
    U - J_H

## SOC

Required symbolic result:

    Delta_E_SOC = 3*lambda_SOC/2

## Physical limits

Required checks:

    J(J_H=0) = 0
    K(J_H=0) = 0
    K(lambda_SOC=0) = 0

## Symmetry

For the stated z-bond C2 operation:

    J_xx = J_yy

## Test independence

Never define an expected result by evaluating the same code path used by
the implementation.

Prefer independently encoded identities.
