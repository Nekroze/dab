#!/bin/sh
# Description: does things
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'

repo="$1"
shift

create_entrypoint_command() {
	repo="$1"
	shift
	config_set "repo/$repo/entrypoint/start/command" "$@"
	config_set "repo/$repo/entrypoint/stop/command" "$@"
}

if [ "$#" -gt 0 ]; then
	create_entrypoint_command "$repo" "$@"
else
	create_entrypoint_command "$repo" echo start "$repo"
fi
