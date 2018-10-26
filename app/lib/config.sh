#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh

config_get() {
	path="$DAB_CONF_PATH/$1"
	[ ! -r "$path" ] || cat "$path"
}

config_set() {
	key="$1"
	shift

	path="$(config_path "$key")"
	if [ -n "${1:-}" ]; then
		[ "$(carelessly cat "$path")" = "$*" ] && return 0
		whisper "setting config key $key to $*"
		mkdir -p "$(dirname "$path")"
		echo "$@" >"$path"
	elif [ -f "$path" ]; then
		whisper "deleting config key $key"
		rm -f "$path"
	fi
}

config_path() {
	echo "$DAB_CONF_PATH/$1"
}

config_chmod() {
	key="$1"
	mode="$2"
	chmod "$mode" "$(config_path "$key")"
	whisper "change $key mode to $mode"
}

config_add() {
	key="$1"
	shift

	[ -n "$1" ] || fatality 'must provide some value to add'

	path="$(config_path "$key")"
	silently grep -E "^$*$" "$path" && return 0
	mkdir -p "$(dirname "$path")"
	echo "$@" >>"$path"
	whisper "added $* to config key $key which now contains $(wc -l <"$path") value(s)"
}

config_load_envs() {
	set +f
	envs="$(config_path 'environment')"
	[ -d "$envs" ] || return 0
	for file in "$envs"/*; do
		name="$(basename "$file")"
		export "$name=$(config_get "environment/$name")"
	done
	set -f
}
