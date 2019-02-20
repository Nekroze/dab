#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

cat <<EOF
title: A Tour Of Dab
scenes:
EOF

filename="$1"
while read -r line; do
	case "$line" in
	'##'* | '# shellcheck'*)
		true
		;;
	'')
		cat <<EOF
  - name: pause 1 second(s)
    pause: 1
  - name: Action - clear
    action: clear
    wait: true
EOF
		true
		;;
	'# '*)
		msg="$(echo "$line" | cut -c3-)"
		cat <<EOF
  - name: Message - $msg
    action: "$line"
EOF
		;;
	*)
		cat <<EOF
  - name: Action - $line
    action: $line
    wait: true
EOF
		;;
	esac
done <"$filename"
