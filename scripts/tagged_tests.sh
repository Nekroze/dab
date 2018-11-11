#!/bin/sh
# Usage: <TAG_EXPRESSION_STRING> [<CUCUMBER_ARGUMENTS>...]
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

export TEST_TAGS="$1"
shift
./scripts/test.sh "$@"
