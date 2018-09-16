Feature: Subcommand: dab config
	The config subcommand manages the dab configuration key value store. Config
	keys are any word or sequence of words (for namespacing) delimited by a
	period, eg. repos.dab.url would store the url for the dab repository.

	Background:
		As though a new user.

		Given the directory "/tmp/dab/repos" does not exist
		And the directory "/tmp/dab/config" does not exist

	Scenario: Can execute config with no parameters and get usage info
		When I run `./dab config`

		Then it should fail with "SUBCOMMAND"

	Scenario: Can execute config with -h and get usage info
		When I run `./dab config -h`

		Then it should pass with "SUBCOMMAND"

	Scenario Outline: Can set and retrieve config values
		The user should be able to get and set arbitrary config key value pairs.

		Given I successfully run `./dab config set <KEY> <VALUE>`

		When I run `./dab config get <KEY>`

		Then it should pass with exactly:
		"""
		<VALUE>
		"""
		And the file "/tmp/dab/config/<KEY>" should contain exactly:
		"""
		<VALUE>
		"""

		Examples:
			| KEY     | VALUE |
			| foo     | bar   |
			| foo     | barry |
			| bar.foo | 42    |

	Scenario Outline: Can add to a config value making a list
		The user should be able to set a config value and then add to it to
		make a list, note setting will replace the list with the single new
		element.

		Given I successfully run `./dab config set <KEY> <FIRST>`

		When I run `./dab config add <KEY> <SECOND>`

		Then it should pass with exactly:
		"""
		added <SECOND> to config key <KEY> which now contains 2 values
		"""
		And the file "/tmp/dab/config/<KEY>" should contain exactly:
		"""
		<FIRST>
		<SECOND>
		"""
		And I run `./dab config get <KEY>`
		And it should pass with exactly:
		"""
		<FIRST>
		<SECOND>
		"""

		Examples:
			| KEY        | FIRST | SECOND |
			| thing1     | foo   | bar    |
			| thing2     | barry | allen  |
			| thing3/foo | 42    | lolwut |

	Scenario Outline: Can erase config items with an empty set
		By not giving a value to assign to a key when running the `config set`
		subcommand that key will be deleted.

		Given I successfully run `./dab config set <KEY> toErase`
		And the file "/tmp/dab/config/<KEY>" should exist

		When I successfully run `./dab config set <KEY>`

		Then the file "/tmp/dab/config/<KEY>" should not exist anymore

		Examples:
			| KEY     |
			| foo     |
			| bar/foo |
