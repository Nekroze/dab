# vim: ts=4 sw=4 sts=4 noet
@ci
Feature: Subcommand: dab group
	The group subcommand manages groups of groups and repostory entrypoints.

	Background:
		Given the aruba exit timeout is 60 seconds

	@smoke
	Scenario: Can group repositories then start them together
		Given I successfully run `dab repo add three https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create three start`
		And I successfully run `dab repo add four https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create four start`

		When I run `dab group repos work three start`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group repos work four start`

		Then it should pass with "contains 2 value(s)"

		When I run `dab group start work `

		Then it should pass with:
		"""
		Executing three entrypoint start
		Executing four entrypoint start
		"""

	Scenario: Can group groups and repos then start them together
		And I successfully run `dab repo add seven https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab group repos subset seven deploy`

		When I run `dab group groups superset subset`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group start superset`

		Then it should pass with:
		"""
		Executing seven entrypoint deploy
		"""
		And I successfully run `docker ps`
