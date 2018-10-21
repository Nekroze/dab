#!/bin/sh
# Description: List available services
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh

get_compose_service_rows 'services' | column -s'`' -o' | ' -t -N SERVICE,DESCRIPTION,USERNAME,PASSWORD -R SERVICE
