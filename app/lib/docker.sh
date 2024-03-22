#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

dpose_all() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] dpose_all $*"

	app_envs_to_files_muxing
	env COMPOSE_PROJECT_NAME=dab \
		COMPOSE_FILE="$(find "$DAB/docker" -type f -name 'docker-compose.*.yml' | tr '\n' ':' | sed 's/:$//')" \
		docker compose --project-directory "$DAB/docker" "$@"

	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose_all $*"
}

get_docker_compose_files_for_app() {
	app="$1"
	out="$DAB/docker/docker-compose.$app.yml"
	for dep in $(get_app_dependencies "$app"); do
		out="$out:$(get_docker_compose_files_for_app "$dep")"
	done
	echo "$out"
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
		docker compose --project-directory "$DAB/docker" "$@" 3>&1 1>&2 2>&3 | sed '/If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up/d'

	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose $*"
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
