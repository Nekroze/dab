#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export TEST_DOCKER="${TEST_DOCKER:-dind}"
export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.$TEST_DOCKER.yml"
trap 'docker-compose stop' EXIT

echo
echo Docker Compose Config
echo
docker-compose config
echo

if [ "$TEST_DOCKER" = 'local' ]; then
	[ -d /tmp/dab ] && sudo rm -rf /tmp/dab
	mkdir -p /tmp/dab
fi

# Cleanup first
docker-compose down --volumes

# Pull/build the latest test images.
docker-compose pull || true

# Start the docker in docker daemon, isolating it from the host.
[ "$TEST_DOCKER" = 'local' ] || docker-compose up -d --remove-orphans docker

# run build container to get the image in dind.
docker-compose run --rm build

# run tests container and pass any params to this script to cucumber.
docker-compose run tests "$@"
