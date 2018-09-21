#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

template_subcommands() {
	subcmd_row shell sh 'Run a shell on the lab network'
	subcmd_row destroy rm,erase,clean 'remove the lab network, containers, and volumes'
}

case "${1:-}" in
shell | sh)
	shift
	netpose run shell "$@"
	;;
destroy | erase | rm | clean)
	netpose down --volumes
	;;
'-h' | '--help' | 'help' | *)
	inform 'Manage the lab network.'
	template_subcommands | draw_subcommand_table
	exit 1
	;;
esac
