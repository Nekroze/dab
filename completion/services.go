package main

import "github.com/posener/complete"

var services = []string{
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
	"telegraf",
	"vault",
	"zookeeper",
	"remote-syslog2",
}

func predictServices(_ complete.Args) []string {
	return services
}
