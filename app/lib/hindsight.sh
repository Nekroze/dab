#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/output.sh"

dab_errored() {
	[ "${LAST_EXIT:-0}" -ne 0 ]
}

record_cmdline() {
	CMDLINE="$(echo "dab $*" | sed -e 's/[[:space:]]*$//')"
	export CMDLINE
}

echo_red() {
	echo_color "$COLOR_RED" "$@" 1>&2
}

captain_hindsight() {
	dab_errored || return 0
	[ -n "$*" ] || return 0

	echo_red "I'm sorry, it looks like the command '$CMDLINE' failed."

	case "$CMDLINE" in
	'dab services'*)
		echo_red "If the service is misbehaving perhaps try 'dab services update'"
		echo_red "If you are unsure what the service is doing try 'dab services logs'"
		echo_red "If the service has some bad data perhaps try 'dab services destroy'"
		;;
	'dab tools'*)
		echo_red "If the service is misbehaving perhaps try 'dab tools update'"
		echo_red "If you are unsure what the tool is doing try 'dab tools logs'"
		echo_red "If the service has some bad data perhaps try 'dab tools destroy'"
		;;
	'dab pki issue'* | 'dab pki renew'*)
		echo_red "If the pki is misbehaving perhaps try 'dab pki ready'"
		echo_red "If the pki has some bad data perhaps try 'dab pki destroy'"
		;;
	'dab pki ready'* | 'dab pki up'*)
		echo_red "If the pki is not starting at all, perhaps investigate with 'dab services logs vaul'"
		echo_red "If the pki is starting up properly perhaps try 'dab services restart vault'"
		echo_red "If the pki has some bad data perhaps try 'dab pki destroy'"
		;;
	'dab config'*)
		echo_red "If the config key needs to be wiped, then give no value to 'dab config set'"
		;;
	esac

	echo_red 'If you believe this to due to a problem with Dab please file a bug report at https://github.com/Nekroze/dab/issues/new?template=bug_report.md'
}
