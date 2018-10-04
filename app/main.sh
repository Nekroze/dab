#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/update.sh
# shellcheck disable=SC1091
. ./lib/dab.sh

maybe_selfupdate_dab
quietly ensure_network

dab "$@"
