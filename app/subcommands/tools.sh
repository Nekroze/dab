#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

toolpose() {
	# Project must not be named dab otherwise test and run containers may be
	# removed causing exit code 137 failures.
	docker-compose \
		--file docker/docker-compose.tools.yml \
		--project-directory ./docker \
		--project-name tools \
		"$@"
}

get_tool_port() {
	docker ps --filter "name=tools_$1_1" --format '{{ .Ports }}' |
		grep -Eo '0\.0\.0\.0\:[0-9]+' |
		cut -d: -f2
}

get_tool_url() {
	port=$(get_tool_port "$1")
	if [ -n "$port" ]; then
		echo "${2:-http}://localhost:$port"
	fi
}

must_be_running() {
	silently docker top "tools_$1_1" || fatality "$1 is not running"
}

standard_tool_subcommands() {
	service="$1"
	subcmd_row start up,ensure "start $service [default]"
	subcmd_row stop down "stop $service"
	subcmd_row address "display address to $service"
	subcmd_row logs log "display $service logs"
	subcmd_row update build,pull "update $service image"
	subcmd_row run "run command in a one off $service container"
	subcmd_row exec "run command in the $service container"
	subcmd_row restart "restart the $service container"
	subcmd_row status ps "status (ps) of the $service container"
}

standard_tool() {
	service="$1"
	case "${2:-}" in
	'-h' | '--help' | help)
		standard_tool_subcommands "$service" | draw_subcommand_table
		;;
	logs | log)
		shift 2
		toolpose logs "$@" "$service"
		;;
	address)
		must_be_running "$service"
		inform "$(get_tool_url "$service")"
		;;
	update | build | pull)
		shift 2
		toolpose pull --include-deps "$service"
		toolpose build --pull --force-rm "$@" "$service"
		;;
	run)
		shift 2
		toolpose run --rm "$service" "$@"
		;;
	exec)
		shift 2
		toolpose exec "$service" "$@"
		;;
	restart)
		toolpose restart --timeout 30 "$service"
		;;
	stop | down)
		toolpose stop --timeout 30 "$service"
		;;
	status | ps)
		toolpose ps "$service"
		;;
	start | up | ensure | *)
		toolpose up --remove-orphans --build -d "$service"
		inform "$service is available at ${COLOR_BLUE}$(get_tool_url "$service")${COLOR_NC}"
		;;
	esac
}

all_tools_subcommands() {
	subcmd_row stop down 'stop all tool containers'
	subcmd_row destroy rm,erase,clean 'remove all tool containers and volumes'
	subcmd_row logs 'display logs for all running tools'
	subcmd_row update build,pull 'update all images'
	subcmd_row restart 'restart all tool containers'
	subcmd_row status ps 'status (ps) of all containers'
}

all_tools() {
	case "${1:-}" in
	logs | log)
		shift
		toolpose logs "$@"
		;;
	update | build | pull)
		shift
		toolpose pull
		toolpose build --pull --force-rm "$@"
		;;
	destroy | rm | erase | clean)
		toolpose down --remove-orphans --volumes
		;;
	restart)
		toolpose restart --timeout 90
		;;
	stop | down)
		toolpose stop --timeout 90
		;;
	status | ps)
		shift
		toolpose ps "$@"
		;;
	'-h' | '--help' | help | *)
		all_tools_subcommands | draw_subcommand_table
		;;
	esac
}

tool_row() {
	echo "$1:$2"
}
tools_subcommands() {
	tool_row all 'Bulk operations to manage all tools'
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
}

case "${1:-}" in
cyberchef | portainer | traefik | ngrok | logspout | watchtower | \
	tick | telegraf | influxdb | kapacitor | sysdig | grafana | consul | serveo)
	standard_tool "$@"
	;;
all)
	shift
	all_tools "$@"
	;;
*)
	inform 'Please select from the available tools'
	tools_subcommands | column -s':' -o' | ' -t -N TOOL,DESCRIPTION
	exit 1
	;;
esac
