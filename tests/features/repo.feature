# vim: ts=4 sw=4 sts=4 noet
@ci
Feature: Subcommand: dab repo
	The repo subcommand manages configured git repositories.

	Background:
		Given the aruba exit timeout is 60 seconds

	Scenario: Cannot clone an unknown repo
		When I run `dab repo clone unknown_repo_name`

		Then it should fail with:
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

		Then the output should match /^REPO\s*|\s*STATUS/
		And the output should match /^dotfiles3\s*|\s*not downloaded/
		And the output should match /^dotfiles4\s*|\s*downloaded/

	Scenario: Can set entrypoint to script
		Given I successfully run `dab repo add dotfiles4 https://github.com/Nekroze/dotfiles.git`

		When I run `dab repo entrypoint create dotfiles4 start`

		Then it should pass with "repo/dotfiles4/entrypoint/start"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles5 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles5`
		And I append to "~/.config/dab/repo/dotfiles5/entrypoint/start" with:
		"""
		echo FOOBAR
		"""

		When I run `dab repo entrypoint run dotfiles5 start`

		Then it should pass with "FOOBAR"

	Scenario: Can put any command in an entrypoint start script
		Given I successfully run `dab repo add dotfiles6 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles6 start`
		And I successfully run `dab config add repo/dotfiles6/entrypoint/start echo FOOBAR`

		When I run `dab repo entrypoint run dotfiles6 start`

		Then it should pass with "FOOBAR"

	@smoke
	Scenario: Can use custom arguments in entrypoints
		Given I successfully run `dab repo add dotfiles7 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles7 start`
		And I successfully run `dab config add repo/dotfiles7/entrypoint/start echo '\"$1\"'`

		When I run `dab repo entrypoint run dotfiles7 start FOO`

		Then it should pass with "FOO"

	Scenario: Can list entrypoints
		Given I successfully run `dab repo add dotfiles8 https://github.com/Nekroze/dotfiles.git`
		And I run `dab repo entrypoint create dotfiles8 bubbahotep`

		When I run `dab repo entrypoint list dotfiles8`

		Then it should pass with "bubbahotep"

	Scenario: Can clone multiple repos at once
		Given a file named "~/.config/dab/repo/dotfiles9/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""
		And a file named "~/.config/dab/repo/dotfiles10/url" with:
		"""
		https://github.com/Nekroze/dotfiles.git
		"""

		When I run `dab repo clone dotfiles10 dotfiles9`

		Then the directory "~/dab/dotfiles9/.git/" should exist
		And the directory "~/dab/dotfiles10/.git/" should exist
