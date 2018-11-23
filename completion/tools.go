package main

import "github.com/posener/complete"

var tools = []string{
	"adminer",
	"ansible",
	"ballerina",
	"chronograf",
	"cyberchef",
	"grafana",
	"huginn",
	"kafkacat",
	"kapacitor",
	"ngrok",
	"ntopng",
	"pgadmin",
	"portainer",
	"serveo",
	"sysdig",
	"traefik",
	"vaultbot",
	"watchtower",
	"xsstrike",
}

func predictTools(_ complete.Args) []string {
	return tools
}
