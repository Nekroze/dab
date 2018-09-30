#!/bin/sh
# Description: Fetch all repos to check for available updates
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'

set +f
for repo in "$DAB_CONF_PATH/repo/"*; do
	maybe_selfupdate_repo "$(echo "$repo" | sed "s/^$DAB_CONF_PATH//")"
done
