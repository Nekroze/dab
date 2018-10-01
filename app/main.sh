#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

maybe_selfupdate_dab
ensure_network

dab "$@"
