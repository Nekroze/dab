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
	config_load_envs || true
	maybe_notify_wrapper_update || true
	maybe_update_completion || true

	case "${1:-}" in
	'-h' | '--help' | 'help' | 'network' | 'update')
		true
		;;
	*)
		maybe_selfupdate_dab || true
		quietly ensure_network || true
		;;
	esac
}
