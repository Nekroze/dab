#!/bin/sh
# Description: Remove the lab network and its tooling
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

netpose down --volumes
