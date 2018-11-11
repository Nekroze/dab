# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab services
	Provides easy access to common/powerful services.

	Background:
		Containers can be fast... but not over
		Australian internet.

		Given the aruba exit timeout is 300 seconds

	@ci @smoke
	Scenario: Can list all available services
		When I run `dab services list`

		Then it should pass with "SERVICE"
		And the output should contain "DESCRIPTION"

	@ci
	Scenario: Can update all services at once
		Given the aruba exit timeout is 3600 seconds

		When I run `dab services update`

		Then it should pass with "Pulling"
		And the output should contain "Building"

	@ci
	Scenario: Can start and stop a service
		Given I successfully run `dab services start influxdb`
		And I run `docker ps`
		And it should pass with "dab_influxdb"

		When I successfully run `dab services stop influxdb`

		Then I successfully run `docker ps`
		And it should not pass with "dab_influxdb"

	Scenario Outline: Can start and stop various services
		Given I successfully run `dab services start <SERVICE>`
		And I run `docker ps`
		And it should pass with "dab_<SERVICE>"

		When I successfully run `dab services stop <SERVICE>`

		Then I successfully run `docker ps`
		And it should not pass with "dab_<SERVICE>"

		Examples:
			| SERVICE        |
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

	Scenario Outline: Can select different service versions with environment variables
		A non exhaustive list of services and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab services start <SERVICE>`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=dab_<SERVICE>'`
		And it should pass with "<VERSION>"
		And I successfully run `dab services destroy <SERVICE>`

		Examples:
			| SERVICE  | VAR                       | VERSION    |
			| influxdb | DAB_SERVICES_INFLUXDB_TAG | 1.5-alpine |
			| postgres | DAB_SERVICES_POSTGRES_TAG | 9.4-alpine |

	@ci
	Scenario: Can stop all services at once
		Given I successfully run `dab services start redis`

		When I run `dab services stop`

		Then I successfully run `docker ps`
		And it should not pass with "dab_redis"

	@ci
	Scenario: Can erase all services and their state at once
		Given I successfully run `dab services start redis`

		When I run `dab services destroy`

		Then I successfully run `docker ps`
		And it should not pass with "dab_redis"

	@ci @smoke
	Scenario: Can view the docker-compose config for a service
		When I run `dab services config vault`

		Then it should pass with:
		"""
		labels:
		  description:
		"""
