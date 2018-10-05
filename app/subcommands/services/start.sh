#!/bin/sh
# Description: Start the container for a given service, or all services if none is given
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/output.sh

servicepose up --remove-orphans --build -d "$@"
