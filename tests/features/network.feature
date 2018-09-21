Feature: Subcommand: dab network
	The network subcommand provides management over the lab network.

	Scenario: Network is ensured to exist
		When I successfully run `./dab -h`

		Then I successfully run `docker network inspect lab`

	Scenario: Can run command in shell
		When I run `./dab network shell ls /`

		Then it should pass with "bin"

	Scenario: Can destroy the lab network
		When I successfully run `./dab network destroy`

		Then I run `docker network inspect lab`
		And it should fail with "No such network"
