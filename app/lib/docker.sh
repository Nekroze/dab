#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/output.sh"

dpose() {
	project="$1"
	shift
	files="$DAB/docker/docker-compose.$project.yml"
	env COMPOSE_FILE="$files" \
		COMPOSE_PROJECT_NAME=dab \
		docker-compose \
		--project-directory ./docker \
		"$@"
}

compose_service_config() {
	project="$1"
	service="$2"
	yq read "$DAB/docker/docker-compose.$project.yml" "services.$service"
}

compose_to_services_data() {
	tmp="$(mktemp)"
	dpose "$1" config >"$tmp"
	yq read "$tmp" services -j |
		jq 'to_entries[] | "\(.key)`\(.value.labels.description)"' -r
}

get_compose_service_label_value() {
	project="$1"
	service="$2"
	label="$3"
	default="${4:-}"
	tmp="$(mktemp)"
	val="$(yq read "docker/docker-compose.$project.yml" "services.$service.labels.$label")"
	[ "$val" != "null" ] || val="$default"
	[ -n "$val" ] && echo "$val"
	true
}

compose_service_to_urls() {
	project="$1"
	service="$2"
	scheme="$(get_compose_service_label_value "$project" "$service" exposing http)"
	id="$(ishmael find dab "$service" || fatality "$service is not running")"
	ishmael address "$id" | xargs --no-run-if-empty printf "$scheme://%s\\n"
}

await_container_healthy_timeout=60
await_container_healthy() {
	id="$1"
	display="${2:-$1}"

	inform "waiting for $display to become healthy..."
	if ! ishmael healthy --wait "$await_container_healthy_timeout" "$id"; then
		fatality "$display did not become healthy within $await_container_healthy_timeout seconds"
	fi
}
