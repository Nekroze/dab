#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet

_find_nssdbs_under() {
	for fname in cert8.db cert9.db; do
		carelessly find "$1" -name "$fname" -type f
	done
}

_find_nssdbs() {
	_find_nssdbs_under ~/.pki
	_find_nssdbs_under ~/.mozilla
	_find_nssdbs_under ~/.config/browsh
	_find_nssdbs_under ~/Library/Application\ Support/Firefox/Profiles
}

find_nssdbs() {
	_find_nssdbs | sort -u
}
