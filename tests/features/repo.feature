Feature: Subcommand: dab repo
	The repo subcommand manages configured git repositories.

	Background:
		As though a new user.

		Given the directory "/tmp/dab/repos" does not exist
		And the directory "/tmp/dab/config" does not exist

	Scenario: Can execute repo with no parameters and get usage info
		When I run `./dab repo`

		Then it should fail with "SUBCOMMAND"

	Scenario: Cannot clone an unknown repo
		When I run `./dab repo clone unknown_repo_name`

		Then it should fail with exactly:
		"""
		url for repo unknown_repo_name is unknown
		"""

	Scenario: Can add a new repository
		Given the directory "/tmp/dab/repos/dotfiles/.git/" should not exist

		When I successfully run `./dab repo add dotfiles https://github.com/Nekroze/dotfiles.git`

		Then the file "/tmp/dab/config/repo/dotfiles/url" should contain exactly:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "/tmp/dab/repos/dotfiles/.git/" should exist

	Scenario: Can clone an existing repository
		Given a file named "/tmp/dab/config/repo/dotfiles/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "/tmp/dab/repos/dotfiles/.git/" should not exist

		When I successfully run `./dab repo clone dotfiles`

		Then the directory "/tmp/dab/repos/dotfiles/.git/" should exist

	Scenario: Can set entrypoint to script
		Given I successfully run `./dab repo add dotfiles https://github.com/Nekroze/dotfiles.git`

		When I run `./dab repo entrypoint dotfiles set script`

		Then it should pass with "Please edit $DAB_CONF_PATH/repo/dotfiles/entrypoint/start/script"

	Scenario: Can put any command in an entrypoint script
		Given I successfully run `./dab repo add dotfiles https://github.com/Nekroze/dotfiles.git`
		And I run `./dab repo entrypoint dotfiles set script`
		And I append to "/tmp/dab/config/repo/dotfiles/entrypoint/start/script" with:
		"""
		echo FOOBAR
		"""

		When I run `./dab repo entrypoint dotfiles start`

		Then it should pass with "FOOBAR"

	Scenario: Can have one repo depend on another
		Given the directory "/tmp/dab/repos/one/.git/" should not exist
		And I successfully run `./dab repo add one https://github.com/Nekroze/dotfiles.git`
		And I successfully run `./dab repo entrypoint one set script`
		And I successfully run `./dab repo add two https://github.com/Nekroze/dotfiles.git`
		And I successfully run `./dab repo entrypoint two set script`
		And the directory "/tmp/dab/repos/two" does not exist
		And I append to "/tmp/dab/config/repo/one/entrypoint/start/script" with:
		"""
		echo FOO
		"""
		And I append to "/tmp/dab/config/repo/two/entrypoint/start/script" with:
		"""
		echo BAR
		"""
		And I successfully run `./dab repo require one two`

		When I run `./dab repo entrypoint one start`

		Then it should pass with:
		"""
		Executing two entrypoint start
		BAR
		Executing one entrypoint start
		FOO
		"""
		And the directory "/tmp/dab/repos/two/.git/" should exist
