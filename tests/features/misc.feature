# vim: ts=4 sw=4 sts=4 noet
@smoke
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

	Scenario: Warns user when wrapper is automatically updated
		Given I set the environment variable "DAB_AUTOUPDATE" to "true"
		And I successfully run `dab -h`
		And the output should not contain:
		"""
		dab was updated!
		"""
		And I append to "/usr/bin/dab" with:
		"""
		# simulated change indicating wrapper is out of date
		"""

		When I successfully run `dab -h`

		Then the output should contain:
		"""
		dab was updated!
		"""
		And the file "/usr/bin/dab" should not contain:
		"""
		# simulated change indicating wrapper is out of date
		"""
		And I set the environment variable "DAB_AUTOUPDATE" to "false"

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

	Scenario: Can set a UID unknown to the host's /etc/passwd
		Given  I set the environment variable "DAB_UID" to "1337"

		When I run `dab shell whoami`

		Then it should pass with "user"

	Scenario: Captain Hindsight comes to the rescue when commands fail
		When I run `dab shell false`

		Then it should fail with:
		"""
		I'm sorry, it looks like the command 'dab shell false' failed.
		"""
		And the stderr should contain:
		"""
		If you believe this to due to a problem with Dab please file a bug report at https://github.com/Nekroze/dab/issues/new?template=bug_report.md
		"""

	@profiling @announce-output
	Scenario: Can profile major events in a dab execution
		Given  I set the environment variable "DAB_PROFILING" to "true"

		Then I successfully run `dab shell true`
