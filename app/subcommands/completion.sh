#!/bin/sh
# Description: Install shell completion
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/update.sh

maybe_update_completion
inform 'The shell completion binary has been placed in your home directory.'
inform 'To install shell completion please execute the following command:'
# shellcheck disable=SC2088
inform '~/.dab-completion -install'
inform
inform 'Should this binary fail to work on your machine you can compile it anew with:'
inform 'go get github.com/Nekroze/dab/completion'
# shellcheck disable=SC2016
inform '$GOPATH/bin/completion -install'
