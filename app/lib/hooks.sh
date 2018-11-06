#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/docker.sh
# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/vault.sh
# shellcheck disable=SC1091
. ./lib/update.sh

maybe_post_chronograf_annotiation() {
	if [ -z "$(dpose services top influxdb)" ]; then
		return 0
	fi
	ns="$(date +%s)000000000"
	values="text=\"dab $1\",start_time=${ns}i,modified_time_ns=${ns}i,type=\"dab execution\",deleted=false"
	dpose services exec --detach influxdb sh -c "
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

pre_hooks() {
	trap post_hooks EXIT

	quietly maybe_post_chronograf_annotiation "$*"

	generate_user

	DAB_SERVICES_VAULT_TOKEN="$(vault_token)"
	export DAB_SERVICES_VAULT_TOKEN

	config_load_envs

	case "${1:-}" in
	'-h' | '--help' | 'help' | 'network' | 'update')
		true
		;;
	*)
		maybe_selfupdate_dab || true
		quietly dpose lab up --no-start || true
		;;
	esac

	maybe_update_completion
}

post_hooks() {
	maybe_display_tip
	maybe_notify_wrapper_update
}
