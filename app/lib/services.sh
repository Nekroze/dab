#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

export DAB_COMPOSE_PREFIX="${DAB_COMPOSE_PREFIX:-}"

get_service_port_random() {
	docker ps --filter "name=${DAB_COMPOSE_PREFIX}services_$1_1" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

get_service_port_host() {
	mode="$(docker inspect "${DAB_COMPOSE_PREFIX}services_$1_1" --format '{{ .HostConfig.NetworkMode }}')"
	if [ "$mode" = "host" ]; then
		docker inspect "${DAB_COMPOSE_PREFIX}services_$1_1" --format '{{ json .HostConfig.PortBindings }}' |
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

service_status() {
	docker inspect "${DAB_COMPOSE_PREFIX}services_${1}_1" --format '{{ .State.Health.Status }}'
}

await_service_healthy_timeout=60
await_service_healthy_increment=5
await_service_healthy() {
	service="$1"

	timespent=0
	waiting='false'
	while [ "$(service_status "$service")" != "healthy" ]; do
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
