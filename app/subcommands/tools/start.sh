#!/bin/sh
# Description: Start the container for a given tool, or all tools if none is given
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

toolpose up --remove-orphans --build -d "$@"

tool="${1:-}"
# If there was no tool (eg when starting all) stop here
[ -z "$tool" ] && exit 0

url="$(get_tool_url "$tool")"
[ -n "$url" ] && inform "$tool is available at ${COLOR_BLUE}$url${COLOR_NC}"
