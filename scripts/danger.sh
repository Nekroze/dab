#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

# You can test danger locally against a pull request, for example:
# ./scripts/danger.sh pr https://github.com/Nekroze/dab/pull/20
set -eu

cd tests

yarn install

if [ "$#" -gt 0 ]; then
	yarn danger "$@"
else
	yarn danger ci
fi
