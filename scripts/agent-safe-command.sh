#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
    echo "usage: scripts/agent-safe-command.sh <command> [args...]" >&2
    exit 2
fi

cmd="$*"

case "$cmd" in
    *"dvc gc"*|*"dvc destroy"*|\
    *"git reset --hard"*|*"git clean -fd"*|\
    *"git push --force"*|*"git push -f"*|\
    *"git branch -D"*)
        echo "AGY SAFETY GATE: forbidden destructive command rejected." >&2
        exit 1
        ;;
esac

exec "$@"
