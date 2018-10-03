#!/bin/sh
# Description: List all repositories
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh

repo_data=''
repo_row() {
	repo_data="$repo_data
$1:$2"
}

set +f
for dir in "$DAB_CONF_PATH"/repo/*; do
	repo="$(basename "$dir")"
	status='not downloaded'
	[ -d "$DAB_REPO_PATH/$repo" ] && status='downloaded'
	repo_row "$repo" "$status"
done
set -f

echo "$repo_data" | column -s':' -o' | ' -t -N REPO,STATUS -R STATUS
