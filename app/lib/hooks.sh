#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/docker.sh"
# shellcheck disable=SC1090
. "$DAB/lib/hindsight.sh"
# shellcheck disable=SC1090
. "$DAB/lib/config.sh"
# shellcheck disable=SC1090
. "$DAB/lib/vault.sh"
# shellcheck disable=SC1090
. "$DAB/lib/update.sh"

maybe_post_chronograf_annotiation() {
	if [ -z "$(ishmael alive dab_influxdb)" ]; then
		return 0
	fi
	ns="$(date +%s)000000000"
	values="text=\"dab $1\",start_time=${ns}i,modified_time_ns=${ns}i,type=\"dab execution\",deleted=false"
	quietly dpose influxdb exec --detach influxdb sh -c "
		influx -execute 'CREATE DATABASE chronograf'
		influx -database chronograf -execute 'INSERT annotations,id=$(uuidgen) $values'
	"
}

hour_in_seconds=3600
tip_interval="$hour_in_seconds"
should_display_tip() {
	[ "${DAB_TIPS:-true}" = 'true' ] || return 1

	last_tip="$(config_get "tips/last")"
	[ -n "$last_tip" ] || return 0

	now="$(date +%s)"
	seconds_since_last_tip="$((now - last_tip))"
	[ "$seconds_since_last_tip" -gt "$tip_interval" ]
}

maybe_display_tip() {
	if should_display_tip; then
		echo
		config_set tips/last "$(date +%s)"
		dab tip
	fi
}

generate_user() {
	echo "$DAB_USER:x:$DAB_UID:$DAB_GID:user:$HOME:/bin/sh" >>/etc/passwd
}

load_vault_token() {
	DAB_SERVICES_VAULT_TOKEN="$(vault_token)"
	export DAB_SERVICES_VAULT_TOKEN
}

ensure_persistent_docker_objects() {
	silently dpose shell up --no-start || true
}

pre_hooks() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] pre_hooks $*"
	if [ -f /tmp/hooked ]; then
		return 0
	else
		touch /tmp/hooked
	fi

	# shellcheck disable=SC2064
	trap "post_hooks $*" EXIT

	load_vault_token
	generate_user
	config_load_envs
	maybe_update_completion &

	case "${1:-}" in
	'version' | 'network' | 'update')
		true # this prevents doing certain actions on trivial subcommands
		;;
	*)
		maybe_selfupdate_dab || true
		maybe_update_wrapper
		ensure_persistent_docker_objects &
		;;
	esac
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] pre_hooks $*"
}

post_hooks() {
	captain_hindsight "$@" # captain hindsight must be first because it captures the exit code
	maybe_display_tip
}
