package main

import "github.com/posener/complete"

var services = []string{
	"ballerina",
	"consul",
	"elasticsearch",
	"influxdb",
	"kafka",
	"logspout",
	"memcached",
	"mysql",
	"nats",
	"postgres",
	"redis",
	"remote-syslog2",
	"telegraf",
	"vault",
	"zookeeper",
}

func predictServices(_ complete.Args) []string {
	return services
}
