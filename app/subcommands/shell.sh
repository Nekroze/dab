#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

if [ $# -gt 0 ]; then
	sh -c "$@"
else
	sh
fi
