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
		Given the directory "/tmp/dab/repos/dotfiles1/.git/" should not exist

		When I successfully run `dab repo add dotfiles1 https://github.com/Nekroze/dotfiles.git`

		Then the file "/tmp/dab/config/repo/dotfiles1/url" should contain exactly:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "/tmp/dab/repos/dotfiles1/.git/" should exist

	Scenario: Can clone an existing repository
		Given a file named "/tmp/dab/config/repo/dotfiles2/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And the directory "/tmp/dab/repos/dotfiles2/.git/" should not exist

		When I successfully run `dab repo clone dotfiles2`

		Then the directory "/tmp/dab/repos/dotfiles2/.git/" should exist

	Scenario: Can set entrypoint to script
		Given I successfully run `dab repo add dotfiles3 https://github.com/Nekroze/dotfiles.git`

		When I run `dab repo entrypoint set script dotfiles3`

		Then it should pass with "Please edit $DAB_CONF_PATH/repo/dotfiles3/entrypoint/start/script"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles4 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint set script dotfiles4`
		And I append to "/tmp/dab/config/repo/dotfiles4/entrypoint/start/script" with:
		"""
		echo FOOBAR
		"""

		When I run `dab repo entrypoint start dotfiles4`

		Then it should pass with "FOOBAR"

	Scenario: Can use entrypoint command default start
		Given I successfully run `dab repo add dotfiles5 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint set command dotfiles5`

		When I run `dab repo entrypoint start dotfiles5`

		Then it should pass with "start dotfiles5"

	Scenario: Can put any command in an entrypoint start command
		Given I successfully run `dab repo add dotfiles6 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint set command dotfiles6 echo FOOBAR`

		When I run `dab repo entrypoint start dotfiles6`

		Then it should pass with "FOOBAR"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles7 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint set script dotfiles7`
		And I successfully run `dab config set repo/dotfiles7/entrypoint/start/command echo FOOBAR`

		When I run `dab repo entrypoint start dotfiles7`

		Then it should pass with "FOOBAR"

	Scenario: Can have one repo depend on another
		Given I successfully run `dab repo add one https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint set command one`
		And I successfully run `dab repo add two https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint set command two`
		And the directory "/tmp/dab/repos/two" does not exist

		When I successfully run `dab repo require one two`

		Then I run `dab repo entrypoint start one`
		And it should pass with:
		"""
		Executing two entrypoint start
		start two
		Executing one entrypoint start
		start one
		"""
		And the directory "/tmp/dab/repos/two/.git/" should exist

	Scenario: Can group repositories then start them together
		Given I successfully run `dab tools stop`
		And I successfully run `dab repo add three https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint set command three`
		And I successfully run `dab repo add four https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint set command four`

		When I run `dab repo group repo work three`

		Then it should pass with "contains 1 value(s)"

		When I run `dab repo group repo work four`

		Then it should pass with "contains 2 value(s)"

		When I run `dab repo group start work `

		Then it should pass with:
		"""
		Executing three entrypoint start
		start three
		Executing four entrypoint start
		start four
		"""

	@announce-output
	Scenario: Can group repositories and tools then start them together
		Given I successfully run `dab tools stop`
		And I successfully run `dab repo add five https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint set command five`
		And I successfully run `dab repo group repo sidehustle five`

		When I run `dab repo group tool sidehustle telegraf`

		Then it should pass with "contains 1 value(s)"

		When I run `dab repo group tool sidehustle cyberchef`

		Then it should pass with "contains 2 value(s)"

		When I run `dab repo group start sidehustle`

		Then the exit status should be 0
		And the output should contain:
		"""
		Executing five entrypoint start
		start five
		"""
		And the output should contain "telegraf is available at http://localhost:"
		And the output should contain "cyberchef is available at http://localhost:"
