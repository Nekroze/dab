#!/bin/sh
# Description: Start the container for a given service, or all services if none is given
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/services.sh

servicepose up --remove-orphans --build -d "$@"

service="${1:-}"
# If there was no service (eg when starting all) stop here
[ -z "$service" ] && exit 0

url="$(get_service_url "$service")"
[ -z "$url" ] || inform "$service is available at ${COLOR_BLUE}$url${COLOR_NC}"
