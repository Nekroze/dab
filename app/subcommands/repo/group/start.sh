#!/bin/sh
# Description: Start a group's repos and then tools if defined, in FIFO order
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a group name to add too'
group_name="$1"
repos="$(config_get "group/$group_name/repos")"
tools="$(config_get "group/$group_name/tools")"

if [ -z "$repos" ] && [ -z "$tools" ]; then
	fatality "group $group_name does not have any dependencies to start"
fi

for repo in $repos; do
	(
		dab repo entrypoint start "$repo"
	)
done

for tool in $tools; do
	(
		dab tools "$tool" start
	)
done
