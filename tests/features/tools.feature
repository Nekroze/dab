Feature: Subcommand: dab tools
	The tools subcommand provides easy access tool common/powerful tools.

	Background:
		Containers are cool, and they can be fast... but not over Australian
		internet.

		Given the aruba exit timeout is 60 seconds

	Scenario: Can execute tools with no parameters and get usage info
		When I run `dab tools`

		Then it should fail with "Please select from the available tools"
		And the stderr should not contain anything

	Scenario: Can update all tools at once
		Given the aruba exit timeout is 3600 seconds

		When I run `dab tools all update`

		Then it should pass with "Pulling"
		And the output should contain "Building"

	Scenario Outline: Can start and stop web based tools
		When I run `dab tools <TOOL> start`

		Then it should pass matching:
		"""
		^<TOOL> is available at https?://localhost:[0-9]+$
		"""
		And I successfully run `docker top tools_<TOOL>_1`

		When I successfully run `dab tools <TOOL> stop`
		And the stderr should not contain anything

		Then I run `docker top tools_<TOOL>_1`
		And it should fail with "is not running"

		Examples:
			| TOOL      |
			| cyberchef |
			| portainer |
			| tick      |
			| kapacitor |
			| telegraf  |
			| influxdb  |
			| traefik   |
			| logspout  |
			| grafana   |

	Scenario: Can stop all tools at once
		Given I successfully run `dab tools cyberchef start`

		When I run `dab tools all stop`

		Then I run `docker top tools_cyberchef_1`
		And it should fail with "is not running"

	Scenario: Can erase all tools and their state at once
		Given I successfully run `dab tools cyberchef start`

		When I run `dab tools all destroy`

		Then I run `docker top tools_cyberchef_1`
		And it should fail with "No such container"
