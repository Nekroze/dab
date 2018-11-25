package main

import "github.com/posener/complete"

var apps = []string{
	"adminer",
	"ansible",
	"ballerina",
	"chronograf",
	"consul",
	"cyberchef",
	"elasticsearch",
	"fn",
	"grafana",
	"huginn",
	"influxdb",
	"kafka",
	"kafkacat",
	"kapacitor",
	"logspout",
	"memcached",
	"mysql",
	"nats",
	"ngrok",
	"ntopng",
	"pgadmin",
	"portainer",
	"postgres",
	"redis",
	"remote-syslog2",
	"serveo",
	"sysdig",
	"telegraf",
	"traefik",
	"vault",
	"vaultbot",
	"vyne",
	"watchtower",
	"xsstrike",
	"zookeeper",
}

func predictApps(_ complete.Args) []string {
	return apps
}
