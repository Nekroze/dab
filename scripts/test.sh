#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.${TEST_DOCKER:=local}.yml"

echo
echo Docker Compose Config
echo
docker-compose config
echo

# Cleanup first
docker-compose down --volumes

# Pull/build the latest test images.
docker-compose pull tests || true

# Ensure the mess we are about to make will be somewhat cleaned up
trap 'docker-compose down' EXIT

if [ "$TEST_DOCKER" = 'local' ]; then
	# Cleanup previous test space
	[ -d /tmp/dab ] && sudo rm -rf /tmp/dab
elif [ "$TEST_DOCKER" = 'dind' ]; then
	# run build container to get the image in dind.
	docker-compose run --rm build

	# Start the docker in docker daemon, isolating it from the host.
	docker-compose up -d --remove-orphans docker
fi

# Create new test space
mkdir -p /tmp/dab/test_results

# run tests container and pass any params to this script to cucumber.
docker-compose run tests --tags="${TEST_TAGS:-not @none}" --order=random "$@"
