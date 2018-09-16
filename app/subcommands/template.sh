#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

template_subcommands() {
	subcmd_row thing 'does cool stuff'
	subcmd_row foo bar,barry 'thingo with two aliases'
}

case "${1:-}" in
*)
	template_subcommands | draw_subcommand_table
	exit 1
	;;
esac
