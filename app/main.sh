#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

maybe_selfupdate_dab

usage() {
	echo "Dab"
	echo "Developer lab."
	echo
	echo "Usage:"
	echo "  $ dab [subcommand]... [options]..."
	echo
	echo "Subcommands:"
	set +f
	find subcommands/* | cut -d/ -f2 | cut -d. -f1
	set -f
	exit "${1:-1}"
}

case "${1:-}" in
'')
	usage
	;;
'-h' | '--help')
	usage 0
	;;
*)
	dab "$@"
	;;
esac
