#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

# shellcheck source=app/lib/config.sh
. "$DAB/lib/config.sh"

FILE_HASH_ALGO=md5
file_hash() {
	"${FILE_HASH_ALGO}sum" "$1" | cut -d' ' -f1
}
day_in_seconds=86400
self_update_period="$day_in_seconds"
should_selfupdate() {
	[ "${DAB_AUTOUPDATE:-true}" = 'true' ] || return 1
	[ "${DAB_AUTOUPDATE_IMAGE:-true}" = 'true' ] || return 1

	last_updated="$(config_get 'updates/last')"
	[ -n "$last_updated" ] || return 0

	now="$(date +%s)"
	seconds_since_last_update="$((now - last_updated))"
	[ "$seconds_since_last_update" -gt "$self_update_period" ]
}

maybe_update_wrapper() {
	if [ "${DAB_AUTOUPDATE:-true}" = 'false' ] || [ "${DAB_AUTOUPDATE_WRAPPER:-true}" = 'false' ] || ! [ -f /tmp/wrapper ] || ! [ -f "$DAB/dab" ]; then
		return 0
	elif [ -r /tmp/wrapper ] && [ -r "$DAB/dab" ] && [ "$(file_hash "$DAB/dab")" != "$(file_hash /tmp/wrapper)" ]; then
		if cat "$DAB/dab" >/tmp/wrapper; then
			warn "Dab wrapper script at $DAB_WRAPPER_PATH was updated!"
		else
			error "Dab wrapper script at $DAB_WRAPPER_PATH could NOT be automatically updated!"
			warn "Please execute 'sudo curl https://raw.githubusercontent.com/Nekroze/dab/master/dab -o $DAB_WRAPPER_PATH' to do so manually"
		fi
	fi
}

maybe_selfupdate_dab() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] maybe_selfupdate_dab"
	should_selfupdate || return 0

	warn "self updating dab!"
	config_set updates/last "$(date +%s)"

	docker pull "${DAB_IMAGE:-${DAB_IMAGE_NAMESPACE:-nekroze}/${DAB_IMAGE_NAME:-dab}:${DAB_IMAGE_TAG:-latest}}"
	/tmp/wrapper changelog "$(cut -c -7 </VERSION)"

	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] maybe_selfupdate_dab"
}

maybe_update_completion() {
	src='/usr/bin/dab-completion-linux'
	[ "$DAB_HOST_UNAME" = "Darwin" ] && src='/usr/bin/dab-completion-darwin'

	dst="$HOME/.dab-completion"
	if [ -x "$dst" ] && silently diff "$src" "$dst"; then
		return 0
	elif [ "${DAB_AUTOUPDATE:-true}" != 'false' ] || [ "${DAB_AUTOUPDATE_COMPLETION:-}" != 'false' ]; then
		cp "$src" "$dst"
	fi
}

get_commits_differing_from_master_in_repo() {
	repo="$1"
	repopath="$DAB_REPO_PATH/$repo"
	(
		if [ -d "$repopath" ]; then
			cd "$repopath" || return
			git rev-list --left-right "$(git rev-parse HEAD)...${DAB_DEFAULT_REMOTE:-origin}/master"
		fi
	)
}

get_uncommitted_changes_in_repo() {
	repo="$1"
	repopath="$DAB_REPO_PATH/$repo"
	(
		if [ -d "$repopath" ]; then
			cd "$repopath" || return
			git status --porcelain || true
		fi
	)
}

check_repo_is_up_to_date() {
	[ -z "$(get_commits_differing_from_master_in_repo "$1")" ]
}

check_repo_is_clean() {
	[ -z "$(get_uncommitted_changes_in_repo "$1")" ]
}
