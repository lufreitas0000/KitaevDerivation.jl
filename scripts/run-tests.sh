#!/bin/sh
set -eu

exec julia --project=. test/runtests.jl
