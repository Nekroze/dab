#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/config.sh

FILE_HASH_ALGO=md5
file_hash() {
	"${FILE_HASH_ALGO}sum" "$1" | cut -d' ' -f1
}
day_in_seconds=86400
self_update_period="$day_in_seconds"
should_selfupdate() {
	[ "${DAB_AUTOUPDATE:-yes}" = 'yes' ] || return 1

	last_updated="$(config_get "${1:-/}updates/last")"
	[ -n "$last_updated" ] || return 0

	now="$(date +%s)"
	seconds_since_last_update="$((now - last_updated))"
	[ "$seconds_since_last_update" -gt "$self_update_period" ]
}

maybe_notify_wrapper_update() {
	if [ ! -f /tmp/wrapper ] || [ ! -f dab ]; then
		return 0
	fi
	if [ "$(file_hash dab)" != "$(file_hash /tmp/wrapper)" ]; then
		warn 'Dab wrapper script appears to have an update available!'
	fi
}
maybe_selfupdate_repo() {
	if should_selfupdate "repo/$1"; then
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
		docker pull nekroze/dab:latest
		/tmp/wrapper changelog "$(cut -c -7 </VERSION)"
	fi
}

maybe_update_completion() {
	src='/usr/bin/dab-completion'
	dst="$HOME/.dab-completion"
	if [ -x "$dst" ] && silently diff "$src" "$dst"; then
		return 0
	elif [ "${DAB_AUTOUPDATE_COMPLETION:-}" != 'false' ]; then
		cp "$src" "$dst"
	fi
}
