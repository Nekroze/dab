#!/bin/sh
# Description: Add to (or create a new) group the given tool as a dependency
# Usage: <GROUP_NAME> <TOOL_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a group name to add too'
[ -n "${2:-}" ] || fatality 'must provide a tool name to add as a dependency'
config_add "group/$1/tools" "$2"
