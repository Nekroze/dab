#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/hindsight.sh"

# Allow scripts to use dab without spawning another container while skipping main
# and executing subcommander directly. For consistency main uses this as well.
dab() {
	record_cmdline "$@"
	dir="$PWD"
	cd "$DAB"

	set +e
	subcommander "$@"
	export LAST_EXIT=$? # captured for captain_hindsight to inspect
	set -e

	[ "$LAST_EXIT" -eq 0 ]
	cd "$dir"
}
