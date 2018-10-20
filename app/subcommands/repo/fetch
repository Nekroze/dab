#!/bin/sh
# Description: Fetch all repos to check for available updates
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/update.sh

set +f
for repo in "$DAB_CONF_PATH/repo/"*; do
	name="$(basename "$repo" | sed "s@^$DAB_CONF_PATH@@")"
	[ ! -d "$DAB_REPO_PATH/$name" ] || maybe_selfupdate_repo "$name"
done
