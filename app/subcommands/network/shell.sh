#!/bin/sh
# Description: Enter a shell in a container on the lab network
# Usage: [<CMD>]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

netpose run shell "$@"
