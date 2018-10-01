#!/bin/sh
# Description: Destroy containers and volumes for a specific (or all if none given) tool
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

toolpose down --remove-orphans --volumes "$@"
