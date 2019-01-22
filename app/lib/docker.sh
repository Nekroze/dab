#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/output.sh"

dpose_all() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] dpose_all $*"
	env COMPOSE_PROJECT_NAME=dab \
		COMPOSE_FILE="$(find "$DAB/docker" -type f -name 'docker-compose.*.yml' | tr '\n' ':' | sed 's/:$//')" \
		docker-compose --project-directory "$DAB/docker" "$@"
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose_all $*"
}

dpose() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] dpose $*"
	app="$1"
	file="$DAB/docker/docker-compose.$app.yml"
	[ -f "$file" ] || fatality "$app is not a defined app"
	shift
	env COMPOSE_PROJECT_NAME=dab \
		COMPOSE_FILE="$(get_docker_compose_files_for_app "$app")" \
		docker-compose --project-directory "$DAB/docker" "$@"
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STOP] dpose $*"
}

compose_app_config() {
	highlight --syntax yaml -O xterm256 "$DAB/docker/docker-compose.$1.yml"
}

compose_to_apps_data() {
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] compose_to_apps_data $*"
	files=""
	# shellcheck disable=SC2044
	for file in $(find "$DAB/docker" -name 'docker-compose.*.yml'); do
		files="$files:$file"
	done

	tmp="$(mktemp)"
	env COMPOSE_PROJET_NAME=dab \
		COMPOSE_FILE="$(echo "$files" | cut -c2-)" \
		docker-compose --project-directory "$DAB/docker" config >"$tmp"
	yq read "$tmp" services -j |
		jq 'to_entries[] | "\(.key)`\(.value.labels.description)"' -r
	[ "${DAB_PROFILING:-false}" = 'false' ] || echo "[PROFILE] $(date '+%s.%N') [STRT] compose_to_apps_data  $*"
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

	val="$(yq read "$file" "services.$app.depends_on")"
	[ "$val" != "null" ] || return 0
	echo "$val" | awk '{ print $2 }'
}

get_app_label_value() {
	app="$1"
	label="$2"
	default="${3:-}"
	val="$(yq read "$DAB/docker/docker-compose.$app.yml" "services.$app.labels.$label")"
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
