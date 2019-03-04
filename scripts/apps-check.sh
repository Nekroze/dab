#!/bin/sh
set -eu

cd app/docker

flags=''
for dcf in docker-compose.*.yml; do
	flags="$flags -f $dcf"
done

# shellcheck disable=SC2086
docker-compose $flags build --force-rm
