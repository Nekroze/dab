# vim: ts=4 sw=4 sts=4 noet
Feature: Docker entrypoint wrapper script works
	The main dab entrypoint is actually a small posix complient shell script
	that wraps docker and starts a container using the dab image for you.

	This script is designed to be lightweight and portable and should rarely be
	updated as the rest of the code for dab lives inside the image.

	Scenario: Can execute dab with no parameters and get usage info
		When I run `dab`

		Then it should fail with "Usage:"

	Scenario: Can execute dab with -h and get usage info
		When I run `dab -h`

		Then it should pass with "Usage:"

	Scenario: Warns user when wrapper is out of date with image wrapper
		Given I successfully run `dab -h`
		And the output should not contain:
		"""
		Dab wrapper script appears to have an update available!
		"""
		And I copy the file "/usr/bin/dab" to "/usr/bin/dab.original"
		And I append to "/usr/bin/dab" with:
		"""
		# simulated change indicating wrapper is out of date
		"""

		When I successfully run `dab -h`

		Then the output should contain:
		"""
		Dab wrapper script appears to have an update available!
		"""
		And I copy the file "/usr/bin/dab.original" to "/usr/bin/dab"

	Scenario: Can view the full changelog
		When I run `dab changelog`

		Then it should pass with:
		"""
		* 13782eb|↓|Use tests tag for tests image to match docker hub tags <Taylor Nekroze Lawson>
		* 25276b8|↓|Improve docker caching <Taylor Nekroze Lawson>
		"""

	Scenario: Dab tip subcommand displays useful tips
		With no custom tips defined

		Given I successfully run `dab config set tips/custom`

		When I run `dab tip`

		Then it should pass with "[tips:dab]"

	Scenario: Displays a tip periodically
		With no custom tips defined

		Given I successfully run `dab config set tips/custom`

		When I run `dab config set tips/last`

		Then it should pass with "[tips:dab]"
