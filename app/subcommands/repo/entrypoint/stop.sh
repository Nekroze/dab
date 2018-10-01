#!/bin/sh
# Description: Execute the stop entrypoint for the given repo
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'

repo="$1"
dab repo clone "$repo"

entrypoint="$(config_get "repo/$repo/entrypoint/stop/command")"
[ -n "$entrypoint" ] || fatality "$repo has no stop entrypoint defined"
cd "$DAB_REPO_PATH/$repo"
$entrypoint
