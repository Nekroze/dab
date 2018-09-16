#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# Alias docker-compose with params we need for the test environment.
alias doco='docker-compose --project-name dab -f tests/docker-compose.yml'

# Pull the last dab image for caching.
doco pull dab || true

# Build just the dab image and clean up.
doco build --force-rm --pull dab
