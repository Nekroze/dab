#!/bin/sh
# Description: List available tools
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh

get_compose_service_rows 'tools' | column -s'`' -o' | ' -t -N TOOL,DESCRIPTION,USERNAME,PASSWORD -R TOOL
