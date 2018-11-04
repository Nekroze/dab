#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh

get_service_port_random() {
	id="$(service_to_id "$1")"
	docker ps --filter "id=$id" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

get_service_port_host() {
	id="$(service_to_id "$1")"
	mode="$(docker inspect "$id" --format '{{ .HostConfig.NetworkMode }}')"
	if [ "$mode" = "host" ]; then
		docker inspect "$id" --format '{{ json .HostConfig.PortBindings }}' |
			jq keys | grep -Eo "[0-9]+" | head -n 1
	fi
}

get_service_port() {
	port="$(get_service_port_random "$1")"
	if [ -z "$port" ]; then
		get_service_port_host "$1"
	else
		echo "$port"
	fi
}

get_service_url() {
	port=$(get_service_port "$1")
	if [ -n "$port" ]; then
		echo "${2:-http}://localhost:$port"
	fi
}

container_health_status() {
	docker inspect "$1" --format '{{ .State.Health.Status }}'
}

service_to_id() {
	servicepose ps -q "$1"
}

await_service_healthy_timeout=60
await_service_healthy_increment=5
await_service_healthy() {
	service="$1"
	id="$(service_to_id "$service")"

	timespent=0
	waiting='false'
	while [ "$(container_health_status "$id")" != "healthy" ]; do
		if ! "$waiting"; then
			inform "Waiting for $service to become healthy"
			waiting='true'
		fi

		sleep "$await_service_healthy_increment"
		timespent="$((timespent + await_service_healthy_increment))"
		if [ "$timespent" -gt "$await_service_healthy_timeout" ]; then
			fatality "service $service did not become healthy within $await_service_healthy_timeout seconds"
		fi
	done
}
