#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export DAB="$PWD"

if [ ! -d tests ]; then
	git clone -b tests https://github.com/Nekroze/dab.git tests
fi

cd ./tests
./scripts/test.sh "$@"
