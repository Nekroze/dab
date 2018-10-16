#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

# Alias docker-compose with params we need for the test environment.
alias doco='docker-compose --project-name dab -f tests/docker-compose.yml'
trap 'doco stop' EXIT

# Cleanup first
doco down --volumes

# Pull/build the latest test images.
doco pull docker build || true
doco build --force-rm tests

# Start the docker in docker daemon, isolating it from the host.
doco up -d --remove-orphans docker

# run build container to get the image in dind.
doco run --rm build

# run tests container and pass any params to this script to cucumber.
doco run tests "$@"
