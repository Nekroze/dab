#!/bin/sh
# Description: Add to (or create a new) group the given service as a dependency
# Usage: <GROUP_NAME> <SERVICE_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh

[ -n "${1:-}" ] || fatality 'must provide a group name to add too'
[ -n "${2:-}" ] || fatality 'must provide a service name to add as a dependency'
config_add "group/$1/services" "$2"
