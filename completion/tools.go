package main

import "github.com/posener/complete"

var tools = []string{
	"cyberchef",
	"portainer",
	"tick",
	"traefik",
	"ngrok",
	"logspout",
	"watchtower",
	"sysdig",
	"grafana",
	"consul",
	"serveo",
	"ntopng",
	"vault",
	"vaultbot",
}

func predictTools(_ complete.Args) []string {
	return tools
}
