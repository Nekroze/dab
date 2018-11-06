#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

dpose() {
	project="$1"
	shift
	files="docker/docker-compose.$project.yml"
	[ "$project" = 'tools' ] && files="$files:docker/docker-compose.services.yml:docker/docker-compose.deps.yml"
	env COMPOSE_FILE="$files" \
		COMPOSE_PROJECT_NAME=dab \
		docker-compose \
		--project-directory ./docker \
		"$@"
}

compose_to_services_data() {
	tmp="$(mktemp)"
	docker-compose -f "docker/docker-compose.$1.yml" config >"$tmp"
	yq read "$tmp" services -j |
		jq 'to_entries[] | "\(.key)`\(.value.labels.description)"' -r
}

container_id_to_random_port() {
	id="$1"
	docker ps --filter "id=$id" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

container_id_to_host_port() {
	id="$1"
	mode="$(docker inspect "$id" --format '{{ .HostConfig.NetworkMode }}')"
	[ "$mode" = "host" ] || return 0
	docker inspect "$id" --format '{{ json .HostConfig.PortBindings }}' |
		jq keys | grep -Eo "[0-9]+" | head -n 1
}

container_id_to_port() {
	port="$(container_id_to_random_port "$1")"
	[ -n "$port" ] || port="$(container_id_to_host_port "$1")"
	echo "$port"
}

container_id_to_url() {
	port=$(container_id_to_port "$1")
	[ -z "$port" ] || echo "${2:-http}://localhost:$port"
}

container_health_status() {
	docker inspect "$1" --format '{{ .State.Health.Status }}'
}

compose_service_to_id() {
	project="$1"
	service="$2"
	dpose "$project" ps -q "$service" | head -n 1
}

await_container_healthy_timeout=60
await_container_healthy_increment=5
await_container_healthy() {
	id="$1"
	display="${2:-$1}"

	timespent=0
	waiting='false'
	while [ "$(container_health_status "$id")" != "healthy" ]; do
		if ! "$waiting"; then
			inform "Waiting for $display to become healthy"
			waiting='true'
		fi

		sleep "$await_container_healthy_increment"
		timespent="$((timespent + await_container_healthy_increment))"
		if [ "$timespent" -gt "$await_container_healthy_timeout" ]; then
			fatality "$display did not become healthy within $await_container_healthy_timeout seconds"
		fi
	done
}
