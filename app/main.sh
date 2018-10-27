#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/hooks.sh
hooks "$@"

APPLICATION='dab'
DESCRIPTION='The Developer Laboratory

Dab is a flexible tool for managing multiple interdependent projects and their orchestration execution, all while providing a friendly user experience and handy devops tools.
'

version_info() {
	echo "Dab Version: $(cat /VERSION)"
	docker info | grep -E '(Runtime(s)|Version|System|Architecture|Version):'
}
VERSION="$(version_info | grep -E '^\w(\w|\s)+:')"
SUBCOMMANDS="$DAB/subcommands"

export APPLICATION DESCRIPTION VERSION SUBCOMMANDS

# shellcheck disable=SC1091
. ./lib/dab.sh
dab "$@"
