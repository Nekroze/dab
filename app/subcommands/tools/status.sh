#!/bin/sh
# Description: display the status of the given tool, or all tools if none is given
# Usage: [<TOOL_NAME>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

toolpose ps "$@"
