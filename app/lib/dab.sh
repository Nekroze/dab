#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# Allow scripts to use dab without spawning another container while skipping main
# and executing subcommander directly. For consistency main uses this as well.
dab() {
	dir="$PWD"
	cd "$DAB"
	subcommander "$@"
	cd "$dir"
}
