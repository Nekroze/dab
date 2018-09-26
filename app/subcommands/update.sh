#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

case "${1:-}" in
'-h' | '--help' | 'help')
	inform "The update subcommand will attempt to udpate the dab image."
	inform "There are no SUBCOMMANDS."
	exit 0
	;;
esac

docker pull nekroze/dab:latest
