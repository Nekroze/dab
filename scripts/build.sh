#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.${TEST_DOCKER:=local}.yml"

# Build just the dab image and clean up.
docker compose build --progress plain --force-rm --pull dab
