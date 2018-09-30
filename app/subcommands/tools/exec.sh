#!/bin/sh
# Description: run a command in the running instance of the given tool
# Usage: <TOOL_NAME> <CMD>...
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a tool name'
tool="$1"
shift

toolpose exec "$tool" "$@"
