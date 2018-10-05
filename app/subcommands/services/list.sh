#!/bin/sh
# Description: List available services
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

service_row() {
	echo "$1:$2"
}

services_subcommands() {
	service_row logspout 'Log routing for Docker container logs, points to tick'
	service_row influxdb 'Time series database'
	service_row consul 'Services discovery and key value store'
	service_row vault 'Store, manage, and generate secrets with Hashicorp Vault'
	service_row redis 'In-memory data structure store'
	service_row postgres 'Object-relational database management system'
}

services_subcommands | column -s':' -o' | ' -t -N SERVICE,DESCRIPTION -R SERVICE
