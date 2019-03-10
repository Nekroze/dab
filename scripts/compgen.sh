#!/bin/sh
set -eu

export GO111MODULE=off

go get -v -u github.com/valyala/quicktemplate/qtc

cd completion
export GO111MODULE=on
go mod download

go generate -v ./templates
go generate -v .
