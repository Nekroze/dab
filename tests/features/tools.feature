# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab tools
	Provides easy access to common/powerful tools.

	Background:
		Containers can be fast... but not over
		Australian internet.

		Given the aruba exit timeout is 300 seconds

	@ci @smoke
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
		Given I run `dab tools start <TOOL>`
		And it should pass matching:
		"""
		^<TOOL> is available at https?://localhost:[0-9]+$
		"""
		And I successfully run `docker ps`
		And it should pass with "dab_<TOOL>"

		When I successfully run `dab tools stop <TOOL>`

		Then I successfully run `docker ps`
		And it should not pass with "dab_<TOOL>"

		Examples:
			| TOOL       |
			| adminer    |
			| ballerina  |
			| chronograf |
			| cyberchef  |
			| grafana    |
			| kapacitor  |
			| kibana     |
			| ngrok      |
			| ntopng     |
			| pgadmin    |
			| portainer  |
			| traefik    |

	Scenario Outline: Can use cli tools through dab
		A non exhaustive list of tools that allow direct execution of their respective applications.

		When I run `dab tools run <TOOL> -h`

		Then the exit status should be 0

		Examples:
			| TOOL     |
			| ansible  |
			| kafkacat |
			| xsstrike |

	Scenario Outline: Can select different tool versions with environment variables
		A non exhaustive list of tools and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab tools start <TOOL>`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=dab_<TOOL>'`
		And it should pass with "<VERSION>"
		And I successfully run `dab tools stop <TOOL>`

		Examples:
			| TOOL       | VAR                      | VERSION    |
			| kapacitor  | DAB_TOOLS_KAPACITOR_TAG  | 1.5-alpine |
			| portainer  | DAB_TOOLS_PORTAINER_TAG  | 1.19.2     |
			| chronograf | DAB_TOOLS_CHRONOGRAF_TAG | 1.5-alpine |
			| chronograf | DAB_TOOLS_CHRONOGRAF_TAG | alpine     |
			| traefik    | DAB_TOOLS_TRAEFIK_TAG    | v1.7       |

	@ci
	Scenario: Can stop all tools at once
		Given I successfully run `dab tools start cyberchef`
		And I successfully run `docker ps`
		And it should pass with "dab_cyberchef"

		When I run `dab tools stop`

		Then I successfully run `docker ps`
		And it should not pass with "dab_cyberchef"

	@ci
	Scenario: Can erase all tools and their state at once
		Given I successfully run `dab tools start cyberchef`

		When I run `dab tools destroy`
		And it should pass with "Stopping dab_cyberchef"

		Then I successfully run `docker ps`
		And it should not pass with "dab_cyberchef"

	@ci @smoke
	Scenario: Can view the docker-compose config for a tool
		When I run `dab tools config cyberchef`

		Then it should pass with:
		"""
		labels:
		  description:
		"""
