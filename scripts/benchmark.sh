#!/bin/sh
# This script will allow you to benchmark the uncomitted/unbuilt changes to a
# dab subcommand against the last built version
set -euf

subcmd="$*"
[ -n "$subcmd" ] || subcmd='shell true'

prep='true'
echo "$subcmd" | grep -v pki >/dev/null 2>&1 || prep='dab pki destroy'

hyperfine \
	--warmup 2 \
	--prepare "$prep" \
	"env DAB_DEV_MOUNT=yes dab $subcmd" \
	"env DAB_DEV_MOUNT=no dab $subcmd"
