#!/bin/sh
# Description: run a command in a new instance of given tool's container
# Usage: <TOOL_NAME> [<CMD>...]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ $# -gt 0 ] || fatality 'must provide at least a tool name'
toolpose run --rm "$@"
