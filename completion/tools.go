package main

import "github.com/posener/complete"

var tools = []string{
	"adminer",
	"chronograf",
	"cyberchef",
	"grafana",
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
}

func predictTools(_ complete.Args) []string {
	return tools
}
