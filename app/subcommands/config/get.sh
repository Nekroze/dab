#!/bin/sh
# Description: Get the value assigned to the given config key
# Usage: <KEY>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality "must provide a config key"
config_get "$1"
