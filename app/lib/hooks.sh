#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/compose.sh
# shellcheck disable=SC1091
. ./lib/config.sh
# shellcheck disable=SC1091
. ./lib/update.sh

hooks() {
	maybe_selfupdate_dab || true
	config_load_envs || true

	case "${1:-}" in
	'-h' | '--help' | 'help' | 'network' | '')
		true
		;;
	*)
		quietly ensure_network || true
		;;
	esac
}
