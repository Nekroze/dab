#!/bin/sh
# Description: list available tools
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

tool_row() {
	echo "$1:$2"
}

tools_subcommands() {
	tool_row cyberchef 'The Cyber Swiss Army Knife'
	tool_row portainer 'Docker Management Web UI'
	tool_row tick 'Telegraf Influxdb Chronograf Kapacitor (TICK) metrics stack'
	tool_row traefik 'The Cloud Native Edge Router, docker reverse proxy'
	tool_row ngrok 'Secure introspectable tunnels, points to traefik'
	tool_row logspout 'Log routing for Docker container logs, points to tick'
	tool_row watchtower 'Watches labelled container images for updates and applies them'
	tool_row sysdig 'Universal system visibility tool with native support for containers'
	tool_row grafana 'The open platform for analytics and monitoring'
	tool_row consul 'Services discovery and key value store'
	tool_row serveo 'Expose local servers to the internet'
	tool_row ntopng 'Monitor network interfaces'
	tool_row vault 'Store, manage, and generate secrets with Hashicorp Vault'
	tool_row vaultbot 'Automate interaction with Hashicorp Vault'
}

tools_subcommands | column -s':' -o' | ' -t -N TOOL,DESCRIPTION
