#!/usr/bin/env bash
set -euo pipefail

#
# Agent command safety guard for KitaevDerivation.jl
#
# This is intentionally NOT a complete shell security parser.
# It is a deterministic policy layer that rejects known-dangerous
# Git/DVC operations before an agent executes them.
#

if [[ $# -eq 0 ]]; then
    echo "ERROR: no command supplied" >&2
    exit 2
fi

COMMAND="$*"

fail() {
    echo "AGENT SAFETY BLOCKED:" >&2
    echo "  $1" >&2
    echo >&2
    echo "Command:" >&2
    echo "  $COMMAND" >&2
    exit 1
}

# ----------------------------------------------------------------------
# Basic shell syntax check.
#
# This detects malformed shell syntax, but DOES NOT make arbitrary shell
# input safe. The explicit policy checks below are still required.
# ----------------------------------------------------------------------

if ! bash -n -c "$COMMAND" 2>/dev/null; then
    fail "command contains invalid shell syntax"
fi

# ----------------------------------------------------------------------
# Destructive Git operations
# ----------------------------------------------------------------------

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+reset[[:space:]]+--hard($|[[:space:];|&]) ]]; then
    fail "git reset --hard is prohibited for agents"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+clean[[:space:]]+.*-f ]]; then
    fail "git clean -f is prohibited for agents"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+checkout[[:space:]]+--[[:space:]] ]]; then
    fail "discarding working-tree changes with git checkout -- is prohibited"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+restore[[:space:]]+.*--worktree ]]; then
    fail "discarding working-tree changes with git restore is prohibited"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+push[[:space:]]+.*(--force|-f) ]]; then
    fail "force-pushing is prohibited for agents"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+branch[[:space:]]+(-D|--delete[[:space:]]+--force) ]]; then
    fail "force-deleting Git branches is prohibited"
fi

# ----------------------------------------------------------------------
# Destructive DVC operations
# ----------------------------------------------------------------------

if [[ "$COMMAND" =~ (^|[[:space:];|&])dvc[[:space:]]+gc($|[[:space:];|&]) ]]; then
    fail "dvc gc is prohibited for agents"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])dvc[[:space:]]+destroy($|[[:space:];|&]) ]]; then
    fail "dvc destroy is prohibited for agents"
fi

if [[ "$COMMAND" =~ (^|[[:space:];|&])dvc[[:space:]]+remove[[:space:]]+.*--outs ]]; then
    fail "destructive DVC output removal is prohibited"
fi

# ----------------------------------------------------------------------
# Repository-wide destructive filesystem operations
# ----------------------------------------------------------------------

if [[ "$COMMAND" =~ (^|[[:space:];|&])rm[[:space:]]+-rf[[:space:]]+(/|\.|\.git|src|test)($|[[:space:];|&]) ]]; then
    fail "recursive deletion of repository paths is prohibited"
fi

# ----------------------------------------------------------------------
# Credentials
# ----------------------------------------------------------------------

if [[ "$COMMAND" == *".dvc/config.local"* ]]; then
    fail "access to .dvc/config.local is prohibited"
fi

# ----------------------------------------------------------------------
# Otherwise allow.
# ----------------------------------------------------------------------

echo "AGENT SAFETY CHECK: ALLOW"
exit 0
