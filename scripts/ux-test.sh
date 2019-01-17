#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export DAB_WRAPPER_PATH="$PWD/dab"
[ -x "$DAB_WRAPPER_PATH" ]

dabux="$(mktemp -d)/dabux"

git clone https://github.com/Nekroze/dabux "$dabux"

cd "$dabux"

./test.sh
