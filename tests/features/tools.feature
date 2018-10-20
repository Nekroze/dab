# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab tools
	Provides easy access to common/powerful tools.

	Background:
		Containers can be fast... but not over
		Australian internet.

		Given the aruba exit timeout is 120 seconds

	Scenario: Can list all available tools
		When I run `dab tools list`

		Then it should pass with "TOOL"
		And the output should contain "DESCRIPTION"

	Scenario: Can update all tools at once
		Given the aruba exit timeout is 3600 seconds

		When I run `dab tools update`

		Then it should pass with "Pulling"
		And the output should contain "Building"

	Scenario Outline: Can start and stop web based tools
		When I run `dab tools start <TOOL>`

		Then it should pass matching:
		"""
		^<TOOL> is available at https?://localhost:[0-9]+$
		"""
		And I successfully run `docker top tools_<TOOL>_1`

		When I successfully run `dab tools stop <TOOL>`
		And the stderr should not contain anything

		Then I run `docker top tools_<TOOL>_1`
		And it should fail with "is not running"

		Examples:
			| TOOL       |
			| cyberchef  |
			| grafana    |
			| kapacitor  |
			| portainer  |
			| chronograf |
			| traefik    |
			| adminer    |
			| pgadmin    |

	Scenario Outline: Can select different tool versions with environment variables
		A non exhaustive list of tools and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab tools start <TOOL>`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=tools_<TOOL>_1'`
		And it should pass with "<VERSION>"
		And I successfully run `dab tools stop <TOOL>`

		Examples:
			| TOOL       | VAR                      | VERSION    |
			| kapacitor  | DAB_TOOLS_KAPACITOR_TAG  | 1.5-alpine |
			| portainer  | DAB_TOOLS_PORTAINER_TAG  | 1.19.2     |
			| chronograf | DAB_TOOLS_CHRONOGRAF_TAG | 1.5-alpine |
			| chronograf | DAB_TOOLS_CHRONOGRAF_TAG | alpine     |
			| traefik    | DAB_TOOLS_TRAEFIK_TAG    | v1.7       |

	Scenario: Can stop all tools at once
		Given I successfully run `dab tools start cyberchef`

		When I run `dab tools stop`

		Then I run `docker top tools_cyberchef_1`
		And it should fail with "is not running"

	Scenario: Can erase all tools and their state at once
		Given I successfully run `dab tools start cyberchef`

		When I run `dab tools destroy`
		And it should pass with "Stopping tools_cyberchef_1 ... done"

		Then I run `docker top tools_cyberchef_1`
		And it should fail with "No such container"
