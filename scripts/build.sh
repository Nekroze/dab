#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.${TEST_DOCKER:-local}.yml"

# Pull the last dab image for caching.
docker-compose pull dab || true

# Build just the dab image and clean up.
docker-compose build --force-rm --pull dab
