#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh

get_tool_port_random() {
	id="$(tool_to_id "$1")"
	docker ps --filter "id=$id" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

get_tool_port_host() {
	id="$(tool_to_id "$1")"
	mode="$(docker inspect "$id" --format '{{ .HostConfig.NetworkMode }}')"
	if [ "$mode" = "host" ]; then
		docker inspect "$id" --format '{{ json .HostConfig.PortBindings }}' |
			jq keys | grep -Eo "[0-9]+" | head -n 1
	fi
}

get_tool_port() {
	port="$(get_tool_port_random "$1")"
	if [ -z "$port" ]; then
		get_tool_port_host "$1"
	else
		echo "$port"
	fi
}

get_tool_url() {
	port=$(get_tool_port "$1")
	if [ -n "$port" ]; then
		echo "${2:-http}://localhost:$port"
	fi
}

tool_to_id() {
	toolpose ps -q "$1"
}
