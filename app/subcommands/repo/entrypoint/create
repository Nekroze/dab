#!/bin/sh
# Description: Create stub entrypoint scripts for the given repo
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name'
repo="$1"

# shellcheck disable=SC2016
DEFAULT_ENTRYPOINT_SCRIPT='#!/bin/sh
set -eu

# Put containers on the lab network by default.
COMPOSE_FILE="docker-compose.yml:$(compose-external-default-network.sh 2.1 lab default)"
export COMPOSE_FILE

# shellcheck disable=SC1090
. "$DAB/lib/dab.sh"
'

entrypoint_script_path() {
	echo "repo/$1/entrypoint/$2"
}

write_script() {
	config_set "$1" "$2"
	config_chmod "$1" +x
}

start_path="$(entrypoint_script_path "$repo" 'start')"
stop_path="$(entrypoint_script_path "$repo" 'stop')"

if [ ! -e "$DAB_CONF_PATH/$start_path" ]; then
	write_script "$start_path" "$DEFAULT_ENTRYPOINT_SCRIPT
# docker-compose up -d"
fi

if [ ! -e "$DAB_CONF_PATH/$stop_path" ]; then
	write_script "$stop_path" "$DEFAULT_ENTRYPOINT_SCRIPT
# docker-compose stop"
fi

inform "Please edit \$DAB_CONF_PATH/$start_path to start up $repo"
inform "Please edit \$DAB_CONF_PATH/$stop_path to stop $repo"
inform "These scripts will be run from the root of the repository"
