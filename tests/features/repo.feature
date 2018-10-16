# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab repo
	The repo subcommand manages configured git repositories.

	Background:
		Given the aruba exit timeout is 60 seconds

	Scenario: Can execute repo with no parameters and get usage info
		When I run `dab repo`

		Then it should fail with "SUBCOMMAND"

	Scenario: Cannot clone an unknown repo
		When I run `dab repo clone unknown_repo_name`

		Then it should fail with exactly:
		"""
		url for repo unknown_repo_name is unknown
		"""

	Scenario: Can add a new repository
		Given the directory "~/dab/dotfiles1/.git/" should not exist

		When I successfully run `dab repo add dotfiles1 https://github.com/Nekroze/dotfiles.git`

		Then the file "~/.config/dab/repo/dotfiles1/url" should contain exactly:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "~/dab/dotfiles1/.git/" should exist

	Scenario: Can clone an existing repository
		Given a file named "~/.config/dab/repo/dotfiles2/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "~/dab/dotfiles2/.git/" should not exist

		When I successfully run `dab repo clone dotfiles2`

		Then the directory "~/dab/dotfiles2/.git/" should exist

	Scenario: Can list repositories
		Given a file named "~/.config/dab/repo/dotfiles3/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "~/dab/dotfiles3/.git/" should not exist
		And I successfully run `dab repo add dotfiles4 https://github.com/Nekroze/dotfiles.git`

		When I successfully run `dab repo list`

		Then it should pass with "REPO      |         STATUS"
		And the output should contain "dotfiles3 | not downloaded"
		And the output should contain "dotfiles4 |     downloaded"

	Scenario: Can set entrypoint to script
		Given I successfully run `dab repo add dotfiles4 https://github.com/Nekroze/dotfiles.git`

		When I run `dab repo entrypoint create dotfiles4`

		Then it should pass with "Please edit $DAB_CONF_PATH/repo/dotfiles4/entrypoint/start"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles5 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles5`
		And I append to "~/.config/dab/repo/dotfiles5/entrypoint/start" with:
		"""
		echo FOOBAR
		"""

		When I run `dab repo entrypoint start dotfiles5`

		Then it should pass with "FOOBAR"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles6 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles6`
		And I successfully run `dab config add repo/dotfiles6/entrypoint/start echo FOOBAR`

		When I run `dab repo entrypoint start dotfiles6`

		Then it should pass with "FOOBAR"

	Scenario: Can use custom arguments in entrypoints
		Given I successfully run `dab repo add dotfiles7 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles7`
		And I successfully run `dab config add repo/dotfiles7/entrypoint/start echo \$1`
		And I successfully run `dab config add repo/dotfiles7/entrypoint/stop echo \$1`

		When I run `dab repo entrypoint start dotfiles7 FOO`

		Then it should pass with "FOO"

		When I run `dab repo entrypoint stop dotfiles7 BAR`

		Then it should pass with "BAR"

	Scenario: Can have one repo depend on another
		Given I successfully run `dab repo add one https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo add two https://github.com/Nekroze/dotfiles.git`
		And the directory "~/dab/two" does not exist

		When I successfully run `dab repo require one two`

		Then I run `dab repo entrypoint start one`
		And it should pass with:
		"""
		Executing two entrypoint start
		two has no start entrypoint defined
		Executing one entrypoint start
		one has no start entrypoint defined
		"""
		And the directory "~/dab/two/.git/" should exist
