#!/bin/sh
# Description: Recreate the lab network and its tooling
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh

netpose down --volumes
netpose up --no-start
