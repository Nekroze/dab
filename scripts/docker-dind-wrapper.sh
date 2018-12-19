#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

docker run \
	-e TEST_TAGS \
	-e TEST_DOCKER \
	-v "$PWD:$PWD" \
	-w "$PWD" \
	--privileged \
	--entrypoint "/bin/sh" \
	--rm \
	docker/stable-dind "$@"
