#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

dpose_all() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] dpose_all $*"

	app_envs_to_files_muxing
	env COMPOSE_PROJECT_NAME=dab \
		COMPOSE_FILE="$(find "$DAB/docker" -type f -name 'docker-compose.*.yml' | tr '\n' ':' | sed 's/:$//')" \
		docker-compose --project-directory "$DAB/docker" "$@"

	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose_all $*"
}

dpose() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] dpose $*"

	app_envs_to_files_muxing
	app="$1"
	file="$DAB/docker/docker-compose.$app.yml"
	[ -f "$file" ] || fatality "$app is not a defined app"
	shift
	env COMPOSE_PROJECT_NAME=dab \
		COMPOSE_FILE="$(get_docker_compose_files_for_app "$app")" \
		docker-compose --project-directory "$DAB/docker" "$@" 3>&1 1>&2 2>&3 | sed '/If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up/d'

	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose $*"
}

compose_app_config() {
	highlight --syntax yaml -O xterm256 "$DAB/docker/docker-compose.$1.yml"
}

compose_to_apps_data() {
	PROFILING="${DAB_PROFILING:-false}"
	export DAB_PROFILING=false

	tmp="$(mktemp)"
	dpose_all config >"$tmp"
	yq -r '.services | to_entries[] | "\(.key)`\(.value.labels.description)"' <"$tmp"

	export DAB_PROFILING="$PROFILING"
}

get_docker_compose_files_for_app() {
	app="$1"
	out="$DAB/docker/docker-compose.$app.yml"
	for dep in $(get_app_dependencies "$app"); do
		out="$out:$(get_docker_compose_files_for_app "$dep")"
	done
	echo "$out"
}

get_app_dependencies() {
	app="$1"

	file="$DAB/docker/docker-compose.$app.yml"
	[ -f "$file" ] || return 0

	val="$(yq -r ".services[\"$app\"].depends_on" <"$file")"
	[ "$val" != "null" ] || return 0

	echo "$val" | sed -e '1d' -e '$d' | cut -d '"' -f 2
}

get_app_label_value() {
	app="$1"
	label="$2"
	default="${3:-}"
	val="$(yq -r ".services[\"$app\"].labels.$label" <"$DAB/docker/docker-compose.$app.yml")"
	[ "$val" != "null" ] || val="$default"
	[ -z "$val" ] || echo "$val"
}

get_app_urls() {
	app="$1"
	scheme="$(get_app_label_value "$app" exposing http)"
	id="$(ishmael find dab "$app" || fatality "$app is not running")"
	ishmael address "$id" | xargs --no-run-if-empty printf "$scheme://%s\\n"
}

await_container_healthy_timeout=60
await_container_healthy() {
	id="$1"
	display="${2:-$1}"

	if ishmael healthy "$id"; then
		return 0
	fi

	inform "waiting for $display to become healthy..."
	if ! ishmael healthy --wait "$await_container_healthy_timeout" "$id"; then
		fatality "$display did not become healthy within $await_container_healthy_timeout seconds"
	fi
}

app_envs_to_files_muxing() {
	for pair in $(env | grep -E '^DAB_APPS_'); do
		key=$(echo "$pair" | cut -d = -f 1)
		val=$(echo "$pair" | cut -d = -f 2)

		app=$(echo "$key" | cut -d _ -f 3 | tr '[:upper:]' '[:lower:]')
		[ -n "$app" ] || continue
		newkey=$(echo "$key" | cut -d _ -f 4-)
		echo "$newkey=$val" >>"/tmp/denvmux/$app.env"
	done
}

ensure_app_envs() {
	mkdir -p /tmp/denvmux

	# shellcheck disable=SC2044
	for dcf in $(find "$DAB/docker" -type f -name 'docker-compose.*.yml'); do
		app=$(basename "$dcf" | cut -d . -f 2)
		touch "/tmp/denvmux/$app.env"
	done
}
