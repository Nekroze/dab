#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -eu

curl \
	-X POST \
	-u "$PR_GITHUB_API_USER:$PR_GITHUB_API_TOKEN" \
	-d '{"title": "Update Stable Branch","head": "master","base": "stable","maintainer_can_modify": true,"body": "Pull patches from master over to stable."}' \
	https://api.github.com/repos/Nekroze/dab/pulls
