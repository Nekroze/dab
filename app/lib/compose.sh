#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

netpose() {
	# Project must not be named dab otherwise test and run containers may be
	# removed causing exit code 137 failures.
	docker-compose \
		--file docker/docker-compose.network.yml \
		--project-directory ./docker \
		--project-name lab \
		"$@"
}

ensure_network() {
	netpose up --no-start
}

toolpose() {
	# Project must not be named dab otherwise test and run containers may be
	# removed causing exit code 137 failures.
	docker-compose \
		--file docker/docker-compose.tools.yml \
		--project-directory ./docker \
		--project-name tools \
		"$@"
}

servicepose() {
	# Project must not be named dab otherwise test and run containers may be
	# removed causing exit code 137 failures.
	docker-compose \
		--file docker/docker-compose.services.yml \
		--project-directory ./docker \
		--project-name services \
		"$@"
}

get_compose_service_rows() {
	yq read "docker/docker-compose.$1.yml" services -j |
		jq 'to_entries[] | "\(.key):\(.value.labels.description)"' -r
}
