#!/bin/sh
# Description: Displays the address of any tools exposed by the tool
# Usage: <TOOL_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/tools.sh
# shellcheck disable=SC1091
. ./lib/output.sh

[ -n "${1:-}" ] || fatality 'must provide a tool name'
tool="$1"

silently docker top "${DAB_COMPOSE_PREFIX}tools_${tool}_1" || fatality "$tool is not running"

inform "$(get_tool_url "$tool")"
