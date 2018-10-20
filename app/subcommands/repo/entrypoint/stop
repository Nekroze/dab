#!/bin/sh
# Description: Execute the stop entrypoint for the given repo
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/dab.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'
repo="$1"
[ -n "${2:-}" ] && shift

inform "Executing $repo entrypoint stop"
dab repo clone "$repo"

entrypoint="$DAB_CONF_PATH/repo/$repo/entrypoint/stop"
if [ ! -x "$entrypoint" ]; then
	warn "$repo has no stop entrypoint defined"
	exit 0
fi

cd "$DAB_REPO_PATH/$repo"
shellcheck "$entrypoint" || true
"$entrypoint" "$@"
