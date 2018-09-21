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
	shift
	[ -n "${1:-}" ] || fatality "must provide a config key"
	key="$1"
	shift
	config_set "$key" "$@"
	;;
get)
	[ -n "${2:-}" ] || fatality "must provide a config key"
	config_get "$2"
	;;
add)
	shift
	[ -n "${1:-}" ] || fatality "must provide a config key"
	key="$1"
	shift
	config_add "$key" "$@"
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
