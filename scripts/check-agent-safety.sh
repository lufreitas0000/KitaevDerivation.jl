#!/usr/bin/env bash
set -euo pipefail

#
# Agent command safety guard for KitaevDerivation.jl
#
# AGY invokes this script as a PreToolUse hook.
# The hook payload is supplied as JSON on stdin.
#
# This is intentionally NOT a complete shell security parser.
# It is a deterministic policy layer that rejects known-dangerous
# Git/DVC/filesystem operations before an agent executes them.
#

fail() {
    echo "AGENT SAFETY BLOCKED:" >&2
    echo "  $1" >&2
    echo >&2
    echo "Command:" >&2
    echo "  ${COMMAND:-<unknown>}" >&2
    exit 1
}

# ----------------------------------------------------------------------
# Read AGY hook payload from stdin and extract the command.
#
# We deliberately use Python's JSON parser rather than attempting
# to parse arbitrary JSON with shell tools.
# ----------------------------------------------------------------------

PAYLOAD="$(cat)"

if [[ -z "$PAYLOAD" ]]; then
    echo "ERROR: empty AGY hook payload" >&2
    exit 2
fi

COMMAND="$(
    python3 -c '
import json
import sys

payload = json.load(sys.stdin)

def find_command(obj):
    if isinstance(obj, dict):
        # Common direct forms.
        for key in ("command", "cmd"):
            value = obj.get(key)
            if isinstance(value, str):
                return value

        # Recursively search nested hook/tool payloads.
        for value in obj.values():
            result = find_command(value)
            if result is not None:
                return result

    elif isinstance(obj, list):
        for value in obj:
            result = find_command(value)
            if result is not None:
                return result

    return None

command = find_command(payload)

if command is None:
    sys.exit(3)

print(command)
' <<< "$PAYLOAD"
)" || {
    echo "ERROR: could not extract command from AGY hook payload" >&2
    exit 2
}

if [[ -z "$COMMAND" ]]; then
    echo "ERROR: extracted command is empty" >&2
    exit 2
fi

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
