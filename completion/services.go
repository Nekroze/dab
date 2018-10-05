package main

import "github.com/posener/complete"

var services = []string{
	"consul",
	"influxdb",
	"logspout",
	"postgres",
	"redis",
	"vault",
}

func predictServices(_ complete.Args) []string {
	return services
}
