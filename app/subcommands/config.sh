#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. lib.sh

subcommands() {
	subcmd_row set 'assign to the given key a value no value to delete it'
	subcmd_row get 'get the value assigned to the given config key'
	subcmd_row add 'add a value to a list config key'
	subcmd_row keys tree 'view all set config keys as a tree branching at a / in each key'
}

case "${1:-}" in
set)
	quietly config_set "$2" "${3:-}"
	;;
get)
	config_get "$2"
	;;
add)
	config_add "$2" "$3"
	;;
keys | tree)
	(
		cd /etc/dab
		# Remove first, last, and empty lines from tree output
		tree | sed \
			-e '1 d' \
			-e '$ d' \
			-e '/^\s*$/d'
	)
	;;
'-h' | '--help' | help)
	subcommands | draw_subcommand_table
	exit 0
	;;
*)
	subcommands | draw_subcommand_table
	exit 1
	;;
esac
