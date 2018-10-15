#!/bin/sh
# Description: Start a group's services, then repos, and then tools (where defined), in FIFO order
# Usage: <GROUP_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/dab.sh

[ -n "${1:-}" ] || fatality 'must provide a group name to add too'
group_name="$1"
groups="$(config_get "group/$group_name/groups")"
repos="$(config_get "group/$group_name/repos")"
tools="$(config_get "group/$group_name/tools")"
services="$(config_get "group/$group_name/services")"

if [ -z "$repos$tools$services$groups" ]; then
	fatality "group $group_name does not have any dependencies to start"
fi

for group in $groups; do
	(
		dab group start "$group"
	)
done

for service in $services; do
	(
		dab services start "$service"
	)
done

for repo in $repos; do
	(
		dab repo entrypoint start "$repo"
	)
done

for tool in $tools; do
	(
		dab tools start "$tool"
	)
done
