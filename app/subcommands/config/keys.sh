#!/bin/sh
# Description: View all set config keys as a tree branching at a / in each key
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

cd "$DAB_CONF_PATH"
# Remove first, last, and empty lines from tree output
tree | sed \
	-e '1 d' \
	-e '$ d' \
	-e '/^\s*$/d'
