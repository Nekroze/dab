#!/bin/sh
# Description: Clone a known repo by name
# Usage: <REPO_NAME>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

[ -n "${1:-}" ] || fatality "must provide a repo name paramater"
repo="$1"
url="$(dab config get "repo/$repo/url")"
[ -n "$url" ] || fatality "url for repo $repo is unknown"
repopath="$DAB_REPO_PATH/$1"
[ ! -d "$repopath" ] || return 0

mkdir -p "$DAB_REPO_PATH"
git clone "$url" "$repopath"
