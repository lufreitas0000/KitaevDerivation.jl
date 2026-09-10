#!/bin/sh
set -eu

if command -v julia >/dev/null 2>&1; then
    julia --project=. -e '
        try
            using JuliaFormatter
            format(".", verbose=true)
        catch err
            @warn "JuliaFormatter unavailable or not configured" exception=(err, catch_backtrace())
        end
    '
else
    echo "Julia executable not found." >&2
    exit 127
fi
