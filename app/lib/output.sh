#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

[ "${DAB_DEBUG:-false}" = 'false' ] || set -x

if [ -z "${COLOR_NC:-}" ]; then
	export COLOR_NC='\e[0m'
	export COLOR_WHITE='\e[1;37m'
	export COLOR_BLACK='\e[0;30m'
	export COLOR_BLUE='\e[0;34m'
	export COLOR_LIGHT_BLUE='\e[1;34m'
	export COLOR_GREEN='\e[0;32m'
	export COLOR_LIGHT_GREEN='\e[1;32m'
	export COLOR_CYAN='\e[0;36m'
	export COLOR_LIGHT_CYAN='\e[1;36m'
	export COLOR_RED='\e[0;31m'
	export COLOR_LIGHT_RED='\e[1;31m'
	export COLOR_PURPLE='\e[0;35m'
	export COLOR_LIGHT_PURPLE='\e[1;35m'
	export COLOR_BROWN='\e[0;33m'
	export COLOR_YELLOW='\e[1;33m'
	export COLOR_GRAY='\e[0;30m'
	export COLOR_LIGHT_GRAY='\e[0;37m'
fi

silently() {
	"$@" >/dev/null 2>&1
}

quietly() {
	"$@" >/dev/null
}

carelessly() {
	"$@" 2>/dev/null || true
}

fatality() {
	# shellcheck disable=SC2039
	echo_color "$COLOR_RED" "$@" 1>&2
	exit 1
}

inform() {
	echo_color "$COLOR_CYAN" "$@"
}

warn() {
	echo_color "$COLOR_YELLOW" "$@" 1>&2
}

whisper() {
	echo_color "$COLOR_LIGHT_GRAY" "$@"
}

echo_color() {
	color="$1"
	shift
	# shellcheck disable=SC2039
	echo -e "${color}$*${COLOR_NC}"
}
