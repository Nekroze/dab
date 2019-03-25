#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

# shellcheck source=app/lib/docker.sh
. "$DAB/lib/docker.sh"
# shellcheck source=app/lib/hindsight.sh
. "$DAB/lib/hindsight.sh"
# shellcheck source=app/lib/config.sh
. "$DAB/lib/config.sh"
# shellcheck source=app/lib/update.sh
. "$DAB/lib/update.sh"

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

ensure_persistent_docker_objects() {
	silently dpose shell up --no-start || true
}

maybe_set_kubeconfig() {
	app_kubeconfig=$DAB_CONF_PATH/apps/kubernetes/config/kubeconfig.yaml
	if [ -z "${KUBECONFIG:-}" ] &&
		[ -f "$app_kubeconfig" ] &&
		[ ! -f ~/.kube/config.yaml ] &&
		[ ! -f ~/.kube/config.yml ]; then
		export KUBECONFIG=$app_kubeconfig
	fi
}

pre_hooks() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] pre_hooks $*"
	maybe_set_kubeconfig

	if [ -f /tmp/hooked ]; then
		return 0
	else
		touch /tmp/hooked
	fi

	# shellcheck disable=SC2064
	trap "post_hooks $*" EXIT

	[ -n "${DAB_UMASK:-}" ] && umask "$DAB_UMASK"

	generate_user
	config_load_envs
	maybe_update_completion &
	ensure_app_envs

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
	wait
}
