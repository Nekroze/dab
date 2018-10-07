package main

import (
	"github.com/posener/complete"
)

var dab = complete.Command{
	Sub: complete.Commands{
		"config": {
			Sub: complete.Commands{
				"add":  {Args: newGeneric(predictConfigKeys, 1)},
				"get":  {Args: newGeneric(predictConfigKeys, 1)},
				"keys": {},
				"set":  {Args: newGeneric(predictConfigKeys, 1)},
			},
		},
		"network": {
			Sub: complete.Commands{
				"destroy": {},
				"shell":   {},
			},
		},
		"pki": {
			Sub: complete.Commands{
				"ready": {},
				"issue": {},
			},
		},
		"repo": {
			Sub: complete.Commands{
				"add":   {Args: newGeneric(predictRepos, 1)},
				"clone": {Args: newGeneric(predictRepos, 1)},
				"entrypoint": {
					Sub: map[string]complete.Command{
						"set": {
							Sub: map[string]complete.Command{
								"command": {Args: newGeneric(predictRepos, 1)},
								"script":  {Args: newGeneric(predictRepos, 1)},
							},
						},
						"start": {Args: newGeneric(predictRepos, 1)},
						"stop":  {Args: newGeneric(predictRepos, 1)},
					},
				},
				"fetch":   {Args: newGeneric(predictRepos, 1)},
				"require": {Args: newGeneric(predictRepos, 1, 2)},
				"group": {
					Sub: map[string]complete.Command{
						"repo": {Args: complete.PredictOr(
							newGeneric(predictGroups, 1),
							newGeneric(predictRepos, 2),
						)},
						"tool": {Args: complete.PredictOr(
							newGeneric(predictGroups, 1),
							newGeneric(predictTools, 2),
						)},
						"services": {Args: complete.PredictOr(
							newGeneric(predictGroups, 1),
							newGeneric(predictServices, 2),
						)},
						"update": {Args: newGeneric(predictGroups, 1)},
						"start":  {Args: newGeneric(predictGroups, 1)},
					},
				},
			},
		},
		"shell": {},
		"tools": {
			Sub: complete.Commands{
				"address": {Args: newGeneric(predictTools, 1)},
				"destroy": {Args: newGeneric(predictTools, 1)},
				"exec":    {Args: newGeneric(predictTools, 1)},
				"list":    {},
				"logs":    {Args: newGeneric(predictTools, 1)},
				"restart": {Args: newGeneric(predictTools, 1)},
				"run":     {Args: newGeneric(predictTools, 1)},
				"start":   {Args: newGeneric(predictTools, 1)},
				"status":  {Args: newGeneric(predictTools, 1)},
				"stop":    {Args: newGeneric(predictTools, 1)},
				"update":  {Args: newGeneric(predictTools, 1)},
			},
		},
		"services": {
			Sub: complete.Commands{
				"address": {Args: newGeneric(predictServices, 1)},
				"destroy": {Args: newGeneric(predictServices, 1)},
				"exec":    {Args: newGeneric(predictServices, 1)},
				"list":    {},
				"logs":    {Args: newGeneric(predictServices, 1)},
				"restart": {Args: newGeneric(predictServices, 1)},
				"run":     {Args: newGeneric(predictServices, 1)},
				"start":   {Args: newGeneric(predictServices, 1)},
				"status":  {Args: newGeneric(predictServices, 1)},
				"stop":    {Args: newGeneric(predictServices, 1)},
				"update":  {Args: newGeneric(predictServices, 1)},
			},
		},
		"update": {},
	},

	GlobalFlags: complete.Flags{
		"-h":     complete.PredictNothing,
		"--help": complete.PredictNothing,
	},
}

func main() {
	complete.New("dab", dab).Run()
}
