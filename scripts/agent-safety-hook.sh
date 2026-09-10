#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo '{"decision":"deny","reason":"Unable to determine Git repository root."}'
    exit 1
}

exec "$REPO_ROOT/scripts/check-agent-safety.sh" "$@"
