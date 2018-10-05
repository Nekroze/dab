package main

import "github.com/posener/complete"

var tools = []string{
	"chronograf",
	"cyberchef",
	"grafana",
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
