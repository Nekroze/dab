#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# Ensure dab image is up to date.
# shellcheck disable=SC1091
. ./scripts/build.sh

# Pull the last dab image for caching.
doco pull test || true

# run test container and pass any params to this script to cucumber.
doco run --rm test "$@"

# cleanup after a successful run.
doco down --volumes
