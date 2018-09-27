package main

import "github.com/posener/complete"

var tools = []string{
	"all",
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
}

func predictTools(_ complete.Args) []string {
	return tools
}
