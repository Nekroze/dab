# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab apps
	Provides easy access to common/powerful apps.

	Background:
		Containers can be fast... but not over
		Australian internet.

		Given the aruba exit timeout is 300 seconds

	@smoke
	Scenario: Can list all available apps
		When I run `dab apps list`

		Then it should pass with "NAME"
		And the output should contain "DESCRIPTION"

	@ci
	Scenario: Can update all apps at once
		Given the aruba exit timeout is 3600 seconds

		When I run `dab apps update`

		Then it should pass with "Pulling"
		And the output should contain "Building"

	@ci
	Scenario: Can start and stop a app
		Given I successfully run `dab apps start influxdb`
		And I run `docker ps`
		And it should pass with "dab_influxdb"

		When I successfully run `dab apps stop influxdb`

		Then I successfully run `docker ps`
		And it should not pass with "dab_influxdb"

	Scenario Outline: Can start and stop web based apps
		Given I run `dab apps start <APP>`
		And it should pass matching:
		"""
		^<APP> is available at https?://([0-9]+\.){3}[0-9]+:[0-9]+$
		"""
		And I successfully run `docker ps`
		And it should pass with "dab_<APP>"

		When I successfully run `dab apps stop <APP>`

		Then I successfully run `docker ps`
		And it should not pass with "dab_<APP>"

		Examples:
			| APP        |
			| adminer    |
			| ballerina  |
			| chronograf |
			| cyberchef  |
			| grafana    |
			| huginn     |
			| kapacitor  |
			| kibana     |
			| ngrok      |
			| ntopng     |
			| pgadmin    |
			| portainer  |
			| traefik    |

	Scenario Outline: Can start and stop various apps
		Given I successfully run `dab apps start <APP>`
		And I run `docker ps`
		And it should pass with "dab_<APP>"

		When I successfully run `dab apps stop <APP>`

		Then I successfully run `docker ps`
		And it should not pass with "dab_<APP>"

		Examples:
			| APP            |
			| consul         |
			| docker-gen     |
			| elasticsearch  |
			| influxdb       |
			| kafka          |
			| logspout       |
			| memcached      |
			| mysql          |
			| nats           |
			| postgres       |
			| redis          |
			| remote-syslog2 |
			| telegraf       |
			| vault          |
			| vyne           |
			| watchtower     |
			| zookeeper      |

	Scenario Outline: Can use cli apps through dab
		When I run `dab apps run <APP> -h`

		Then the exit status should be 0

		Examples:
			| APP      |
			| ansible  |
			| dive     |
			| fn       |
			| kafkacat |
			| xsstrike |

	Scenario Outline: Can select different app versions with environment variables
		A non exhaustive list of apps and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab apps start <APP>`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=dab_<APP>'`
		And it should pass with "<VERSION>"
		And I successfully run `dab apps destroy <APP>`

		Examples:
			| APP        | VAR                     | VERSION    |
			| chronograf | DAB_APPS_CHRONOGRAF_TAG | 1.5-alpine |
			| chronograf | DAB_APPS_CHRONOGRAF_TAG | alpine     |
			| influxdb   | DAB_APPS_INFLUXDB_TAG   | 1.5-alpine |
			| kapacitor  | DAB_APPS_KAPACITOR_TAG  | 1.5-alpine |
			| portainer  | DAB_APPS_PORTAINER_TAG  | 1.19.2     |
			| postgres   | DAB_APPS_POSTGRES_TAG   | 9.4-alpine |
			| traefik    | DAB_APPS_TRAEFIK_TAG    | v1.7       |

	@ci
	Scenario: Can stop all apps at once
		Given I successfully run `dab apps start redis`

		When I run `dab apps stop`

		Then I successfully run `docker ps`
		And it should not pass with "dab_redis"

	@ci
	Scenario: Can erase all apps and their state at once
		Given I successfully run `dab apps start redis`

		When I run `dab apps destroy`

		Then I successfully run `docker ps`
		And it should not pass with "dab_redis"

	@smoke
	Scenario: Can view the docker-compose config for a app
		When I run `dab apps config vault`

		Then it should pass with "description:"
