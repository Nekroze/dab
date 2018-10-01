#!/bin/sh
# Description: Execute the start entrypoint for the given repo
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'

repo="$1"
for dep in $(config_get "repo/$repo/deps/repos"); do
	(
		"$0" "$dep"
	)
done

inform "Executing $1 entrypoint start"
dab repo clone "$repo"

entrypoint="$(config_get "repo/$repo/entrypoint/start/command")"
[ -n "$entrypoint" ] || fatality "$repo has no start entrypoint defined"
cd "$DAB_REPO_PATH/$repo"
$entrypoint
