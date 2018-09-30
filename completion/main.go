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
						"update": {Args: newGeneric(predictGroups, 1)},
						"start":  {Args: newGeneric(predictGroups, 1)},
					},
				},
			},
		},
		"shell":  {},
		"tools":  {Args: newGeneric(predictTools, 1)},
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
