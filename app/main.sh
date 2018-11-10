#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/hooks.sh
pre_hooks "$@"

APPLICATION='dab'
DESCRIPTION='The Developer Laboratory

Dab is a flexible tool for managing multiple interdependent projects and their orchestration execution, all while providing a friendly user experience and handy devops tools.
'

SUBCOMMANDS="$DAB/subcommands"

export APPLICATION DESCRIPTION SUBCOMMANDS

# shellcheck disable=SC1091
. dab "$@"
