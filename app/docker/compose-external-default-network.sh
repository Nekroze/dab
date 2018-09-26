#!/bin/sh
set -euf
version="${1:-3.5}"
network="${2:-lab}"
aliasnm="${3:-default}"
output="$(mktemp)"

echo "
version: '$version'

networks:
  $aliasnm:
    external:
      name: '$network'
" >"$output"

echo "$output"
