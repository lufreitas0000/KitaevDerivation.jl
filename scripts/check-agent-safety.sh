#!/usr/bin/env bash
set -euo pipefail

PAYLOAD="$(cat)"
if [[ -z "$PAYLOAD" ]]; then
    exit 2
fi

COMMAND="$(
    python3 -c '
import json
import sys

payload = json.load(sys.stdin)

def find_command(obj):
    if isinstance(obj, dict):
        for key in ("command", "cmd", "CommandLine"):
            value = obj.get(key)
            if isinstance(value, str):
                return value
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
)" || exit 2

if [[ -z "$COMMAND" ]]; then
    exit 2
fi

# Extract the first word (the command binary)
BINARY=$(echo "$COMMAND" | head -n 1 | awk '{print $1}')

# Check allowlist
ALLOWED=0
for cmd in julia git dvc cat ls grep find head tail sed awk; do
    if [[ "$BINARY" == "$cmd" ]]; then
        ALLOWED=1
        break
    fi
done

if [[ $ALLOWED -eq 0 ]]; then
    echo "AGENT SAFETY BLOCKED: Command $BINARY is not in the allowlist." >&2
    exit 1
fi

# Check destructive operations
if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+reset[[:space:]]+--hard($|[[:space:];|&]) ]]; then
    exit 1
fi
if [[ "$COMMAND" =~ (^|[[:space:];|&])git[[:space:]]+clean[[:space:]]+.*-f ]]; then
    exit 1
fi
if [[ "$COMMAND" =~ (^|[[:space:];|&])dvc[[:space:]]+destroy($|[[:space:];|&]) ]]; then
    exit 1
fi

exit 0
