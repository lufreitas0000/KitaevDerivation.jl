---
name: dvc-artifacts
description: Defines safe Git/DVC handling for large symbolic ASTs, numerical datasets, and generated scientific artifacts.
---

# Git / DVC Artifact Protocol

## Git

Git is for:

    source code
    tests
    Lean code
    documentation
    project metadata
    .dvc pointer files

## DVC

DVC is for:

    large symbolic AST serializations
    large expression trees
    generated numerical datasets
    expensive intermediate data

## Allowed

    dvc add <artifact>
    dvc push

Then commit the generated `.dvc` pointer with Git.

## Forbidden

Never execute:

    dvc gc
    dvc destroy

Never access or print credential material.

Never modify:

    .dvc/config.local

## Context protection

Do not print large data or AST contents into agent transcripts.

Report:

    path
    byte size
    checksum
    DVC status

instead.
