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

## File Writing and Diagnostics

Agents MUST NEVER use bash commands like `cat > file` or `echo > file` to create test, scratch, or source files. These commands trigger the local Agent Safety Gate and halt execution.

All file creation and modification MUST be done natively using the `write_to_file` or `replace_file_content` tools. Temporary diagnostic tests should ideally be added to existing files in the `test/` directory, or generated as proper Julia files in a designated `test/scratch/` folder using `write_to_file`.
