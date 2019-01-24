package main

import "github.com/posener/complete"

var dab = complete.Command{
	Sub: complete.Commands{
		"config": {
			Sub: complete.Commands{
				"add": {Args: newGeneric(predictConfigKeys, 1)}, "append": {Args: newGeneric(predictConfigKeys, 1)},
				"get": {Args: newGeneric(predictConfigKeys, 1)}, "retrieve": {Args: newGeneric(predictConfigKeys, 1)},
				"keys": {}, "tree": {},
				"set": {Args: newGeneric(predictConfigKeys, 1)}, "update": {Args: newGeneric(predictConfigKeys, 1)}, "change": {Args: newGeneric(predictConfigKeys, 1)},
			},
		},
		"network": {
			Sub: complete.Commands{
				"destroy": {}, "delete": {},
				"shell": {}, "sh": {}, "cmd": {},
			},
		},
		"pki": {
			Sub: complete.Commands{
				"ready": {}, "up": {},
				"issue": {}, "renew": {},
				"destroy": {}, "delete": {},
			},
		},
		"repo": {
			Sub: complete.Commands{
				"add": {Args: newGeneric(predictRepos, 1)}, "url": {Args: newGeneric(predictRepos, 1)}, "register": {Args: newGeneric(predictRepos, 1)},
				"clone": {Args: newGeneric(predictRepos, 1)}, "download": {Args: newGeneric(predictRepos, 1)},
				"list": {}, "check": {},
				"fetch": {Args: newGeneric(predictRepos, 1)}, "update": {Args: newGeneric(predictRepos, 1)},
				"entrypoint": {
					Sub: map[string]complete.Command{
						"create": {Args: newGeneric(predictRepos, 1)}, "new": {Args: newGeneric(predictRepos, 1)},
						"list": {Args: newGeneric(predictRepos, 1)}, "available": {Args: newGeneric(predictRepos, 1)},
						"run": {Args: complete.PredictOr(
							newGeneric(predictRepos, 1),
							newGeneric(predictEntrypoint, 2),
						)},
						"exec": {Args: complete.PredictOr(
							newGeneric(predictRepos, 1),
							newGeneric(predictEntrypoint, 2),
						)},
						"script": {Args: complete.PredictOr(
							newGeneric(predictRepos, 1),
							newGeneric(predictEntrypoint, 2),
						)},
					},
				},
			},
		},
		"group": {
			Sub: map[string]complete.Command{
				"repos": {Args: complete.PredictOr(
					newGeneric(predictGroups, 1),
					newGeneric(predictRepos, 2),
				)},
				"repo": {Args: complete.PredictOr(
					newGeneric(predictGroups, 1),
					newGeneric(predictRepos, 2),
				)},
				"groups": {Args: newGeneric(predictGroups, 1, 2)}, "group": {Args: newGeneric(predictGroups, 1, 2)},
				"start": {Args: newGeneric(predictGroups, 1)},
				"run":   {Args: newGeneric(predictGroups, 1)},
			},
		},
		"apps": {
			Sub: complete.Commands{
				"address": {Args: newGeneric(predictApps, 1)}, "url": {Args: newGeneric(predictApps, 1)},
				"destroy": {Args: newGeneric(predictApps, 1)}, "delete": {Args: newGeneric(predictApps, 1)},
				"exec": {Args: newGeneric(predictApps, 1)},
				"list": {}, "available": {},
				"logs": {Args: newGeneric(predictApps, 1)}, "log": {Args: newGeneric(predictApps, 1)},
				"restart": {Args: newGeneric(predictApps, 1)},
				"run":     {Args: newGeneric(predictApps, 1)},
				"config":  {Args: newGeneric(predictApps, 1)},
				"start":   {Args: newGeneric(predictApps, 1)}, "up": {Args: newGeneric(predictApps, 1)},
				"status": {Args: newGeneric(predictApps, 1)}, "ps": {Args: newGeneric(predictApps, 1)},
				"stop": {Args: newGeneric(predictApps, 1)}, "down": {Args: newGeneric(predictApps, 1)},
				"update": {Args: newGeneric(predictApps, 1)}, "upgrade": {Args: newGeneric(predictApps, 1)},
			},
		},
		"shell": {}, "sh": {}, "cmd": {},
		"tip":    {},
		"update": {}, "upgrade": {},
		"changelog": {}, "changes": {},
	},

	GlobalFlags: complete.Flags{
		"-h":        complete.PredictNothing,
		"--help":    complete.PredictNothing,
		"-v":        complete.PredictNothing,
		"--version": complete.PredictNothing,
	},
}

func main() {
	complete.New("dab", dab).Run()
}
