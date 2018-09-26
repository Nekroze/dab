Feature: Subcommand: dab tools
	Provides easy access to common/powerful tools.

	Background:
		Containers can be fast... but not over
		Australian internet.

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

	Scenario Outline: Can select different tool versions with environment variables
		A non exhaustive list of tools and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab tools <TOOL> start`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=tools_<TOOL>_1'`
		And it should pass with "<VERSION>"
		And I successfully run `dab tools <TOOL> stop`

		Examples:
			| TOOL      | VAR                      | VERSION    |
			| tick      | DAB_TOOLS_CHRONOGRAF_TAG | latest     |
			| tick      | DAB_TOOLS_CHRONOGRAF_TAG | alpine     |
			| tick      | DAB_TOOLS_CHRONOGRAF_TAG | 1.5        |
			| tick      | DAB_TOOLS_CHRONOGRAF_TAG | 1.5-alpine |
			| tick      | DAB_TOOLS_CHRONOGRAF_TAG | 1.6-alpine |
			| portainer | DAB_TOOLS_PORTAINER_TAG  | 1.19.2     |
			| influxdb  | DAB_TOOLS_INFLUXDB_TAG   | 1.5-alpine |
			| kapacitor | DAB_TOOLS_KAPACITOR_TAG  | 1.5-alpine |
			| traefik   | DAB_TOOLS_TRAEFIK_TAG    | v1.7       |
			| logspout  | DAB_TOOLS_LOGSPOUT_TAG   | v3.1       |
			| consul    | DAB_TOOLS_CONSUL_TAG     | 1.1.0      |

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
