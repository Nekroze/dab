# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab services
	Provides easy access to common/powerful services.

	Background:
		Containers can be fast... but not over
		Australian internet.

		Given the aruba exit timeout is 60 seconds

	Scenario: Can list all available services
		When I run `dab services list`

		Then it should pass with "SERVICE"
		And the output should contain "DESCRIPTION"

	Scenario: Can update all services at once
		Given the aruba exit timeout is 3600 seconds

		When I run `dab services update`

		Then it should pass with "Pulling"
		And the output should contain "Building"

	Scenario Outline: Can start and stop web based services
		When I run `dab services start <SERVICE>`

		Then the exit status should be 0
		And I successfully run `docker top services_<SERVICE>_1`

		When I successfully run `dab services stop <SERVICE>`
		And the stderr should not contain anything

		Then I run `docker top services_<SERVICE>_1`
		And it should fail with "is not running"

		Examples:
			| SERVICE       |
			| influxdb      |
			| telegraf      |
			| elasticsearch |
			| logspout      |
			| redis         |
			| postgres      |
			| vault         |
			| consul        |

	Scenario Outline: Can select different service versions with environment variables
		A non exhaustive list of services and versions that can be configured.

		Given I set the environment variable "<VAR>" to "<VERSION>"

		When I successfully run `dab services start <SERVICE>`

		Then I run `docker ps --format '{{ .Image }}' --filter 'name=services_<SERVICE>_1'`
		And it should pass with "<VERSION>"
		And I successfully run `dab services stop <SERVICE>`

		Examples:
			| SERVICE       | VAR                            | VERSION    |
			| influxdb      | DAB_SERVICES_INFLUXDB_TAG      | 1.5-alpine |
			| postgres      | DAB_SERVICES_POSTGRES_TAG      | 9.4-alpine |

	Scenario: Can stop all services at once
		Given I successfully run `dab services start redis`

		When I run `dab services stop`

		Then I run `docker top services_redis_1`
		And it should fail with "is not running"

	Scenario: Can erase all services and their state at once
		Given I successfully run `dab services start redis`

		When I run `dab services destroy`

		Then I run `docker top services_redis_1`
		And it should fail with "No such container"
