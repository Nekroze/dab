#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export TEST_DOCKER="${TEST_DOCKER:-dind}"
export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.$TEST_DOCKER.yml"
trap 'docker-compose stop' EXIT

# Cleanup first
docker-compose down --volumes

# Pull/build the latest test images.
docker-compose pull || true
docker-compose build --force-rm tests

# Start the docker in docker daemon, isolating it from the host.
[ "$TEST_DOCKER" = 'local' ] || docker-compose up -d --remove-orphans docker

# run build container to get the image in dind.
docker-compose run --rm build

# run tests container and pass any params to this script to cucumber.
docker-compose run tests "$@"
