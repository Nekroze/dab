#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

docker run \
    -e TEST_TAGS \
    -e TEST_DOCKER \
    -v /tmp:/tmp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w "$PWD" \
	--entrypoint "/bin/sh" \
	--rm \
    docker/compose:1.23.2 "$@"
