#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

export COLOR_NC='\e[0m'
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'

# Command wrappers to handle output or errors in specific ways.
silently() {
	"$@" >/dev/null 2>&1
}

quietly() {
	"$@" >/dev/null
}

carelessly() {
	"$@" 2>/dev/null || true
}

# Logging functions.
fatality() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_RED}$*${COLOR_NC}" 1>&2
	exit 1
}

inform() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_CYAN}$*${COLOR_NC}"
}

warn() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_YELLOW}$*${COLOR_NC}"
}

whisper() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_GRAY}$*${COLOR_NC}"
}

# allow scripts to use dab without spawning another container by skipping main
# and executing subcommands directly. For consistency main uses this as well.
dab() {
	sub="subcommands/$1.sh"
	[ -f "$sub" ] || fatality "$1 is not a valid subcommand!"
	shift
	"$sub" "$@"
}

FILE_HASH_ALGO=md5
file_hash() {
	"${FILE_HASH_ALGO}sum" "$1" | cut -d' ' -f1
}

# config helpers
config_get() {
	path="/etc/dab/$1"
	[ ! -r "$path" ] || cat "$path"
}

config_set() {
	key="$1"
	shift

	path="/etc/dab/$key"
	if [ -n "${1:-}" ]; then
		whisper "setting config key $key to $*"
		mkdir -p "$(dirname "$path")"
		echo "$@" >"$path"
	elif [ -f "$path" ]; then
		whisper "deleting config key $key"
		rm -f "$path"
	fi
}

config_add() {
	key="$1"
	shift

	[ -n "$1" ] || fatality "must provide some value to add"

	path="/etc/dab/$key"
	mkdir -p "$(dirname "$path")"
	echo "$@" >>"$path"
	whisper "added $* to config key $key which now contains $(wc -l <"$path") values"
}

# Auto update functionality
day_in_seconds=86400
should_selfupdate() {
	[ "${DAB_AUTOUPDATE:-yes}" = 'yes' ] || return 1

	last_updated="$(config_get "${1:-/}updates/last")"
	[ -n "$last_updated" ] || return 0

	now="$(date +%s)"
	seconds_since_last_update="$((now - last_updated))"
	[ "$seconds_since_last_update" -gt "$day_in_seconds" ]
}

maybe_notify_wrapper_update() {
	if [ ! -f /tmp/wrapper ] || [ ! -f dab ]; then
		tree /tmp
		return 0
	fi
	if [ "$(file_hash dab)" != "$(file_hash /tmp/wrapper)" ]; then
		warn 'Dab wrapper script appears to have an update available!'
	fi
}
maybe_selfupdate_repo() {
	if should_selfupdate "repo.$1"; then
		inform "checking $1 repo for updates"
		(
			cd "$DAB_REPO_PATH/$1"
			out="$(git fetch)"
			if echo "$out" | silently grep origin/master; then
				inform "$1 repo has updates on origin/master!"
			fi
		)
	fi
}
maybe_selfupdate_dab() {
	if should_selfupdate; then
		inform "self updating dab!"
		config_set updates/last "$(date +%s)"
		./subcommands/update.sh
	fi
	maybe_notify_wrapper_update
}

netpose() {
	# Project must not be named dab otherwise test and run containers may be
	# removed causing exit code 137 failures.
	docker-compose \
		--file docker/docker-compose.network.yml \
		--project-directory ./docker \
		--project-name lab \
		"$@"
}

ensure_network() {
	quietly netpose up --no-start
}

# Subcommand table display
alias draw_subcommand_table="sort -s -k 1,1 | column -s':' -o' | ' -t -N SUBCOMMAND,ALIASES,DESCRIPTION -R SUBCOMMAND"
subcmd_row() {
	cmd="$1"
	aliases=""
	desc="$2"
	if [ "$#" -eq 3 ]; then
		aliases="$2"
		desc="$3"
	fi
	echo "$cmd:$aliases:$desc"
}
