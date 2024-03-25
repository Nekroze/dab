#!/bin/sh
set -eu

go install github.com/valyala/quicktemplate/qtc@latest

cd completion
go mod download

go generate -v ./templates
go generate -v .
