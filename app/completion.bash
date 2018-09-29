#!/usr/bin/env bash

_dab() {
	set -u
    local current="${COMP_WORDS[COMP_CWORD]}"
    #local previous="${COMP_WORDS[COMP_CWORD-1]}"
    local switches="--help -h"
    COMPREPLY=()

    if [[ ${current} == -* ]] ; then
        mapfile -t COMPREPLY <(compgen -W "${switches}" -- "${current}")
        return 0
    fi
}
complete -F _dab dab
