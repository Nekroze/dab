#!/bin/sh
# Description: Execute the start entrypoint for the given repo
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/dab.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'
repo="$1"
[ -n "${2:-}" ] && shift

for dep in $(config_get "repo/$repo/deps/repos"); do
	"$0" "$dep"
done

inform "Executing $repo entrypoint start"
dab repo clone "$repo"

entrypoint="$DAB_CONF_PATH/repo/$repo/entrypoint/start"
if [ ! -x "$entrypoint" ]; then
	warn "$repo has no start entrypoint defined"
	exit 0
fi

cd "$DAB_REPO_PATH/$repo"
shellcheck "$entrypoint" || true
"$entrypoint" "$@"
