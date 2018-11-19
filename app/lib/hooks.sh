#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/docker.sh
# shellcheck disable=SC1091
. ./lib/hindsight.sh
# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/vault.sh
# shellcheck disable=SC1091
. ./lib/update.sh

maybe_post_chronograf_annotiation() {
	if [ -z "$(ishmael alive "$(ishmael find dab influxdb)")" ]; then
		return 0
	fi
	ns="$(date +%s)000000000"
	values="text=\"dab $1\",start_time=${ns}i,modified_time_ns=${ns}i,type=\"dab execution\",deleted=false"
	quietly dpose services exec --detach influxdb sh -c "
		influx -execute 'CREATE DATABASE chronograf'
		influx -database chronograf -execute 'INSERT annotations,id=$(uuidgen) $values'
	"
}

hour_in_seconds=3600
tip_interval="$hour_in_seconds"
should_display_tip() {
	[ "${DAB_TIPS:-yes}" = 'yes' ] || return 1

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
	silently dpose persist up --no-start || true
}

pre_hooks() {
	# shellcheck disable=SC2064
	trap "post_hooks $*" EXIT

	record_cmdline "$@"
	load_vault_token
	generate_user
	config_load_envs
	maybe_update_completion

	maybe_post_chronograf_annotiation "$*"

	case "${1:-}" in
	'version' | 'network' | 'update')
		true
		;;
	*)
		maybe_selfupdate_dab || true
		ensure_persistent_docker_objects
		;;
	esac
}

post_hooks() {
	maybe_display_tip
	maybe_notify_wrapper_update
	captain_hindsight "$@"
}
