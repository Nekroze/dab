#!/bin/sh
# Can be given dab subcommands to generate a CPU Flamegraph for using linux
# perf_events
set -eu

subcmd="$*"
[ -n "$subcmd" ] || subcmd='shell true'

cd "$(mktemp -d)"

perf="$(mktemp --suffix .perf)"
folded="$(mktemp --suffix .folded)"
graph="$(mktemp --suffix .svg)"

# shellcheck disable=SC2086
sudo perf record -F 99 -a -g -- dab $subcmd
# shellcheck disable=SC2024
sudo perf script >"$perf"

stackcollapse-perf.pl "$perf" >"$folded"
flamegraph.pl "$folded" >"$graph"

echo
echo "Graph located at $graph"

xdg-open "$graph" >/dev/null 2>&1 || true
