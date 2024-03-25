#!/bin/sh
set -eu

tools=$(go list -f '{{range .Imports}}{{.}}@latest{{end}}' completion/tools.go)
echo "$tools"
go install "$tools"

cd completion
go mod download

go generate -v ./templates
go generate -v .
