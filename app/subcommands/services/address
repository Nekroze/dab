#!/bin/sh
# Description: Displays the address of any services exposed by the service
# Usage: <TOOL_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/services.sh
# shellcheck disable=SC1091
. ./lib/output.sh

[ -n "${1:-}" ] || fatality 'must provide a service name'
service="$1"

silently docker top "services_${service}_1" || fatality "$service is not running"

inform "$(get_service_url "$service")"
