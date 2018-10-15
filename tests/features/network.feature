# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab network
	The network subcommand provides management over the lab network.

	Background:
		As a mildly patient user.

		Given the aruba exit timeout is 60 seconds

	Scenario: Network is ensured to exist
		When I successfully run `dab -h`

		Then I successfully run `docker network inspect testlab`

	Scenario: Can run command in shell
		When I run `dab network shell ls /`

		Then it should pass with "bin"

	Scenario: Can recreate the lab network
		Given I successfully run `dab tools destroy`
		And I successfully run `dab services destroy`

		When I successfully run `dab network recreate`

		Then I successfully run `docker network inspect testlab`
