#!/bin/sh
# Description: Set the given repo to a script style entrypoint
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'
repo="$1"

# shellcheck disable=SC2016
DEFAULT_ENTRYPOINT_SCRIPT='#!/bin/sh
set -eu

# Put containers on the lab network by default.
export COMPOSE_FILE="$(compose-external-default-network.sh 2.1 lab default)"
'

entrypoint_script_path() {
	echo "repo/$1/entrypoint/$2/script"
}

start_path="$(entrypoint_script_path "$repo" 'start')"
stop_path="$(entrypoint_script_path "$repo" 'stop')"

config_set "repo/$repo/entrypoint/start/command" "sh /etc/dab/$start_path"
if [ ! -f "/etc/dab/$start_path" ]; then
	config_set "repo/$repo/entrypoint/start/script" "$DEFAULT_ENTRYPOINT_SCRIPT"
fi

config_set "repo/$repo/entrypoint/stop/command" "sh /etc/dab/$stop_path"
if [ ! -f "/etc/dab/$stop_path" ]; then
	config_set "repo/$repo/entrypoint/stop/script" "$DEFAULT_ENTRYPOINT_SCRIPT"
fi

inform "Please edit \$DAB_CONF_PATH/$start_path to start your project"
inform "Please edit \$DAB_CONF_PATH/$stop_path to stop your project"
inform "These scripts will be run from the root of the repository"
