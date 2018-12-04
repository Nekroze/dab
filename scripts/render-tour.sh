#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eufx

export TEST_DOCKER='dind'
export COMPOSE_PROJECT_NAME='dab'
export COMPOSE_FILE="tests/docker-compose.yml:tests/docker-compose.$TEST_DOCKER.yml"
trap 'docker-compose stop' EXIT

# Start the docker in docker daemon, isolating it from the host.
docker-compose up -d --remove-orphans docker

# Ensure the dab image is built from the code
docker-compose run --rm build
docker-compose build tourist

# Ensure output will not be filled/slowed with progress indicators
docker-compose run --rm tourist 'docker pull nekroze/containaruba:alpine'
apps="$(grep -E 'dab apps \w+ \w+' tests/tour.sh | awk -vORS=' ' '{ print $4; }' | uniq)"
docker-compose run --rm tourist "dab apps update vault vaultbot consul $apps"
docker-compose run --rm tourist 'rm -rf ~/.config/dab'

# Record tour
docker-compose run --rm tourist

# Ensure you own the newly rendered tour
if [ ! -w app/tour.asciinema.json ]; then
	sudo chown "$USER:$(id -g)" app/tour.asciinema.json
	sudo chmod 644 app/tour.asciinema.json
fi
