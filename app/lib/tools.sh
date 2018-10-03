#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

get_tool_port_random() {
	docker ps --filter "name=tools_$1_1" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

get_tool_port_host() {
	mode="$(docker inspect "tools_$1_1" --format '{{ .HostConfig.NetworkMode }}')"
	if [ "$mode" = "host" ]; then
		docker inspect "tools_$1_1" --format '{{ json .HostConfig.PortBindings }}' |
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
