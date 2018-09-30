#!/bin/sh
# Description: Add another repo to start before this one
# Usage: <REPO_NAME> <DEPENDANT_REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality "must provide a repo name to add the dependency too as the first paramater"
[ -n "${2:-}" ] || fatality "must provide a repo name to add as a dependency as the second paramater"
config_add "repo/$1/deps/repos" "$2"
