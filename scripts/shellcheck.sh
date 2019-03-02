#!/bin/sh
set -eu

# shellcheck disable=SC2046
shellcheck --shell sh --color dab app/bin/* $(find . -name '*.sh' -type f) $(find app/subcommands -type f)
