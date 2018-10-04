# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab shell
	The shell subcommand gives access to the dab environment from which all
	scripts are executed, this is mostly for debug purposes.

	Scenario: Can pass through commands to the shell
		When I run `dab shell ls`

		Then it should pass with "main.sh"

	Scenario: All DAB_ env vars are passed into the dab container
		Given I set the environment variable "DAB_CUSTOM_VAR" to "FOOBAR"

		When I run `dab shell env`

		Then it should pass with:
		"""
		DAB_CUSTOM_VAR=FOOBAR
		"""
