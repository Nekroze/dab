#!/bin/sh
# Description: List available tools
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

tool_row() {
	echo "$1:$2"
}

tools_subcommands() {
	tool_row cyberchef 'The Cyber Swiss Army Knife'
	tool_row portainer 'Docker Management Web UI'
	tool_row chronograf 'Chronograf metrics explorer from the TICK stack'
	tool_row kapacitor 'Real-Time metrics processing from the TICK stack'
	tool_row traefik 'The Cloud Native Edge Router, docker reverse proxy'
	tool_row ngrok 'Secure introspectable tunnels, points to traefik'
	tool_row watchtower 'Watches labelled container images for updates and applies them'
	tool_row sysdig 'Universal system visibility tool with native support for containers'
	tool_row grafana 'The open platform for analytics and monitoring'
	tool_row serveo 'Expose local servers to the internet'
	tool_row ntopng 'Monitor network interfaces, requires redis service'
	tool_row vaultbot 'Automate interaction with Hashicorp Vault'
	tool_row pgadmin 'Postgres administration console, usr:pw=user@dab:admin'
}

tools_subcommands | column -s':' -o' | ' -t -N TOOL,DESCRIPTION -R TOOL
