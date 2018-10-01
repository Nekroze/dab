#!/bin/sh
# Description: Set the given repo to a command style entrypoint
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'

repo="$1"
shift

config_set "repo/$repo/entrypoint/start/command" echo start "$repo"
config_set "repo/$repo/entrypoint/stop/command" echo stop "$repo"
