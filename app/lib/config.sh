#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

config_get() {
	path="$(config_path "$1")"
	if [ -r "$path" ]; then
		cat "$path"
	elif [ -n "${2:-}" ]; then
		echo "$2"
	fi
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
	elif [ -e "$path" ]; then
		whisper "deleting config key $key"
		rm -rf "$path"
	fi
}

config_path() {
	echo "$DAB_CONF_PATH/$1"
}

config_chmod() {
	key="$1"
	mode="$2"
	chmod "$mode" "$(config_path "$key")"
	whisper "$key mode changed to $mode"
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
	envs="$(config_path 'environment')"
	[ -d "$envs" ] || return 0

	# shellcheck disable=SC2044
	for file in $(find "$envs" -type f | sort); do
		name="$(basename "$file")"
		export "$name=$(config_get "environment/$name" | envsubst)"
	done
}
