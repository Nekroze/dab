#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

case "${1:-}" in
'-h' | '--help' | 'help')
	inform "The shell subcommand can be used to enter the dab container in a shell, alternatively you could also give commands to be run as parameters non-interactively."
	inform "Available SUBCOMMANDS are any commmands available within the dab container."
	exit 0
	;;
esac

if [ $# -gt 0 ]; then
	sh -c "$@"
else
	sh
fi
