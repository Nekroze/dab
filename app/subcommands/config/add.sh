#!/bin/sh
# Description: Add a value to a list config key
# Usage: <KEY> <VALUE>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality "must provide a config key"
key="$1"
shift

config_add "$key" "$@"
