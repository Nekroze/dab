# vim: ts=4 sw=4 sts=4 noet
@ci
Feature: Subcommand: dab group
	The group subcommand manages groups of groups and repostory entrypoints.

	Background:
		Given the aruba exit timeout is 60 seconds

	@smoke
	Scenario: Can list defined groups
		Given I successfully run `dab repo add one https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab group repos mylist one deploy`

		When I run `dab group list`

		Then it should pass with:
		"""
		mylist
		"""

	@smoke
	Scenario: Can group repositories then start them together
		Given I successfully run `dab repo add three https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create three start`
		And I append to "~/.config/dab/repo/three/entrypoint/start" with:
		"""
		cat
		"""
		And I successfully run `dab repo add four https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create four start`

		When I run `dab group repos work three start`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group repos work four start`

		Then it should pass with "contains 2 value(s)"

		When I run `dab group start work`

		Then it should pass with:
		"""
		Executing three entrypoint start
		Executing four entrypoint start
		"""

	Scenario: Can group repositories fail fast
		Given I successfully run `dab repo add successOne https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create successOne start`
		And I successfully run `dab repo add failure https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create failure start`
		And I append to "~/.config/dab/repo/failure/entrypoint/start" with:
		"""
		exit 1
		"""
		And I successfully run `dab repo add successTwo https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create successTwo start`

		When I run `dab group repos failfast successOne start`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group repos failfast failure start`

		Then it should pass with "contains 2 value(s)"

		When I run `dab group repos failfast successTwo start`

		Then it should pass with "contains 3 value(s)"

		When I run `dab group start failfast`

		Then it should fail with:
		"""
		Executing successOne entrypoint start
		Executing failure entrypoint start
		dab repo entrypoint run failure start exploded
		"""

	Scenario: Can group groups and repos then start them together
		Given I successfully run `dab repo add seven https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab group repos subset seven deploy`

		When I run `dab group groups superset subset`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group start superset`

		Then it should pass with:
		"""
		Executing seven entrypoint deploy
		"""
		And I successfully run `docker ps`

	Scenario: Can add entrypoint to group with aditional arguments
		Given I successfully run `dab repo add eight https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create eight start`

		When I run `dab group repos args eight start --test-arg -D 1`

		Then it should pass with "contains 1 value(s)"

		When I run `dab group start args`

		Then it should pass with:
		"""
		Executing eight entrypoint start --test-arg -D 1
		"""
