#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

# shellcheck disable=SC2016
DEFAULT_ENTRYPOINT_SCRIPT='#!/bin/sh
set -eu

# Put containers on the lab network by default.
export COMPOSE_FILE="$(compose-external-default-network.sh 2.1 lab default)"
'

add_repo() {
	config_set "repo/$1/url" "$2"
}

ensure_repo() {
	repo="$1"
	url="$(dab config get "repo/$repo/url")"
	[ -n "$url" ] || fatality "url for repo $repo is unknown"
	[ ! -d "$(repo_path "$repo")" ] || return 0

	mkdir -p "$DAB_REPO_PATH"
	git clone "$url" "$(repo_path "$repo")"
}

repo_path() {
	echo "$DAB_REPO_PATH/$1"
}

run_entrypoint_start() {
	repo="$1"
	for dep in $(config_get "repo/$repo/deps/repos"); do
		(
			run_entrypoint_start "$dep"
		)
	done

	inform "Executing $1 entrypoint start"
	ensure_repo "$repo"

	entrypoint="$(config_get "repo/$repo/entrypoint/start/command")"
	[ -n "$entrypoint" ] || fatality "$repo has no start entrypoint defined"
	(
		cd "$DAB_REPO_PATH/$repo"
		$entrypoint
	)
}

run_entrypoint_stop() {
	repo="$1"
	ensure_repo "$repo"

	entrypoint="$(config_get "repo/$repo/entrypoint/stop/command")"
	[ -n "$entrypoint" ] || fatality "$repo has no stop entrypoint defined"
	(
		cd "$DAB_REPO_PATH/$repo"
		$entrypoint
	)
}

entrypoint_script_path() {
	echo "repo/$1/entrypoint/$2/script"
}

create_entrypoint_scripts() {
	repo="$1"
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
}

create_entrypoint_command() {
	config_set "repo/$1/entrypoint/start/command" "echo start $1"
	config_set "repo/$1/entrypoint/stop/command" "echo stop $1"
}

entrypoint_subcommands() {
	repo="$1"
	subcmd_row start "execute start $repo entrypoint [default subcommand]"
	subcmd_row stop "execute stop $repo entrypoint"
	subcmd_row set "change the $repo entrypoints"
}

entrypoint() {
	repo="$1"
	case "${2:-}" in
	'-h' | '--help' | help)
		entrypoint_subcommands "$repo" | draw_subcommand_table
		;;
	set)
		shift 2
		entrypoint_set "$repo" "$@"
		;;
	stop)
		run_entrypoint_stop "$repo"
		;;
	start | *)
		run_entrypoint_start "$repo"
		;;
	esac
}

entrypoint_set_subcommands() {
	subcmd_row script 'use start and stop scripts (ideally idempotent ones) stored in dab config'
	subcmd_row command 'run any command within the dab shell after entering the repo directory'
}

entrypoint_set() {
	repo="$1"
	[ -n "$(dab config get "repo/$repo/url")" ] || fatality "url for $repo is unknown"
	case "${2:-}" in
	script)
		create_entrypoint_scripts "$repo"
		;;
	command)
		shift
		create_entrypoint_command "$repo" "$@"
		;;
	'-h' | '--help' | help | *)
		inform "Entrypoints are start stop pairs of commands to execute from inside the repository."
		entrypoint_set_subcommands "$repo" | draw_subcommand_table
		;;
	esac
}

repo_subcommands() {
	subcmd_row add 'configure/add a repo by giving a name and the url'
	subcmd_row clone 'clone a known repo by name'
	subcmd_row entrypoint 'manage a repositories execution lifecycle'
	subcmd_row fetch 'fetch all repos to check for available updates'
	subcmd_row require 'add another repo to start before this one'
}

case "${1:-}" in
add)
	shift
	[ -n "${1:-}" ] || fatality "must provide a repo name as the first parameter"
	[ -n "${2:-}" ] || fatality "must provide a repo url as the second parameter"
	add_repo "$1" "$2"
	ensure_repo "$1"
	;;
clone)
	shift
	[ -n "${1:-}" ] || fatality "must provide a repo name paramater"
	ensure_repo "$1"
	;;
require)
	shift
	[ -n "${1:-}" ] || fatality "must provide a repo name to add the dependency too as the first paramater"
	[ -n "${2:-}" ] || fatality "must provide a repo name to add as a dependency as the second paramater"
	config_add "repo/$1/deps/repos" "$2"
	;;
entrypoint)
	shift
	entrypoint "$@"
	;;
fetch)
	repos="$(
		cd "$DAB_CONF_PATH"
		ls
	)"
	for repo in $repos; do
		maybe_selfupdate_repo "$repo"
	done
	;;
*)
	repo_subcommands | draw_subcommand_table
	exit 1
	;;
esac
