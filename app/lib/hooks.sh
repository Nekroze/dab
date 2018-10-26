#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/vault.sh
# shellcheck disable=SC1091
. ./lib/update.sh

maybe_post_chronograf_annotiation() {
	if ! silently docker top services_influxdb_1; then
		return 0
	fi
	ns="$(date +%s)000000000"
	values="text=\"dab $1\",start_time=${ns}i,modified_time_ns=${ns}i,type=\"dab execution\",deleted=false"
	servicepose exec --detach influxdb sh -c "
		influx -execute 'CREATE DATABASE chronograf'
		influx -database chronograf -execute 'INSERT annotations,id=$(uuidgen) $values'
	"
}

hooks() {
	quietly maybe_post_chronograf_annotiation "$*" || true
	DAB_SERVICES_VAULT_TOKEN="$(vault_token)"
	export DAB_SERVICES_VAULT_TOKEN

	config_load_envs || true
	maybe_notify_wrapper_update || true
	maybe_update_completion || true

	case "${1:-}" in
	'-h' | '--help' | 'help' | 'network' | 'update')
		true
		;;
	*)
		maybe_selfupdate_dab || true
		quietly ensure_network || true
		;;
	esac
}
