#!/bin/sh
# Description: Install shell completion
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib.sh

cp completion ~/.dab-completion
echo 'The shell completion binary has been placed in your home directory.'
echo 'To install shell completion please execute the following command:'
# shellcheck disable=SC2088
echo '~/.dab-completion -install'
echo
echo 'Should this binary fail to work on your machine you can compile it anew with:'
echo 'go get github.com/Nekroze/dab/completion'
# shellcheck disable=SC2016
echo '$GOPATH/bin/completion -install'
