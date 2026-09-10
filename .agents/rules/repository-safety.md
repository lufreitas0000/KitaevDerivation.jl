# Repository Safety Rules

## Forbidden commands

Agents must not execute:

    dvc gc
    dvc destroy
    git reset --hard
    git clean -fd
    git push --force
    git branch -D

## Credential files

Never read, print, modify, or stage:

    .dvc/config.local
    .env
    .env.*
    credentials.*
    *.pem
    *.key

## Large files

Raw artifacts under `data/` should be DVC tracked when they exceed the
project threshold.

The deterministic repository scripts are authoritative.

## Agent scope

Do not modify unrelated phases.

Do not perform broad refactors during physics implementation tasks.
