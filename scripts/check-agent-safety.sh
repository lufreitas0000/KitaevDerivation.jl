#!/bin/sh
set -eu

input="$(cat)"

case "$input" in
    *'"toolCall"'*) ;;
    *) printf '%s\n' '{}' ; exit 0 ;;
esac

if printf '%s\n' "$input" | grep -Eq \
  'dvc[[:space:]]+(gc|destroy)|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+clean[[:space:]]+-fd|git[[:space:]]+push[[:space:]]+-+force|git[[:space:]]+push[[:space:]]+-f'; then
    printf '%s\n' '{"decision":"deny","reason":"Repository safety rule: destructive Git/DVC command rejected."}'
    exit 0
fi

printf '%s\n' '{"decision":"allow"}'
