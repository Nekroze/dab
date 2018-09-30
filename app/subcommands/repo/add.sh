#!/bin/sh
# Description: Add a repo by giving a name and the url
# Usage: <REPO_NAME> <GIT_URL>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality 'must provide a repo name as the first parameter'
[ -n "${2:-}" ] || fatality 'must provide a repo url as the second parameter'
config_set "repo/$1/url" "$2"

dab repo clone "$1"
