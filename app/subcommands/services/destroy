#!/bin/sh
# Description: Destroy containers and volumes for a specific (or all if none given) service
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/output.sh

if [ -n "${1:-}" ]; then
	servicepose rm --stop -v -f "$@"
	silently docker volume inspect "services_$1" && docker volume rm "services_$1"
else
	servicepose down --remove-orphans --volumes
fi
