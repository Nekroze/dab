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
		And I copy the file "/bin/dab" to "/bin/dab.original"
		And I append to "/bin/dab" with:
		"""
		# simulated change indicating wrapper is out of date
		"""

		When I successfully run `dab -h`

		Then the output should contain:
		"""
		Dab wrapper script appears to have an update available!
		"""
		And I copy the file "/bin/dab.original" to "/bin/dab"

	Scenario Outline: All sub commands provide usage imformation via --help and variations
		Given I run `dab <SUBCOMMAND> --help`
		And it should pass with "SUBCOMMAND"

		When I run `dab <SUBCOMMAND> -h`
		And it should pass with "SUBCOMMAND"

		Then I run `dab <SUBCOMMAND> help`
		And it should pass with "SUBCOMMAND"

		Examples:
			| SUBCOMMAND           |
			| config               |
			| shell                |
			| network              |
			| repo                 |
			| repo entrypoint test |
			| repo group test      |
			| tools cyberchef      |
			| tools all            |
