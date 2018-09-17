#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

cd tests

yarn install
yarn danger ci
