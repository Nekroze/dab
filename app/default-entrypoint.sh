#!/bin/sh
set -eu

# Put containers on the lab network by default.
COMPOSE_FILE="docker-compose.yml:$(compose-external-default-network.sh 2.1 lab default)"
export COMPOSE_FILE

# shellcheck disable=SC1090
. "$DAB/lib/dab.sh"
