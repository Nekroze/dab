#!/bin/sh
# Description: Assign to the given key a value no value to delete it
# Usage: <KEY> [<VALUE>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh

[ -n "${1:-}" ] || fatality 'must provide a config key'
key="$1"
shift
config_set "$key" "$@"
