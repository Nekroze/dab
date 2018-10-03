#!/bin/sh
# Description: Update dab
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/update.sh

case "${1:-}" in
'-h' | '--help' | 'help')
	inform 'The update subcommand will attempt to udpate the dab image.'
	inform 'There are no SUBCOMMANDS.'
	exit 0
	;;
esac

export self_update_period=10
maybe_selfupdate_dab
