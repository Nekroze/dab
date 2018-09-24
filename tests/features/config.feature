Feature: Subcommand: dab config
	The config subcommand manages the dab configuration key value store. Config
	keys are any word or sequence of words (for namespacing) delimited by a
	period, eg. repos/dab/url would store the url for the dab repository.

	Scenario: Can execute config with no parameters and get usage info
		When I run `dab config`

		Then it should fail with "SUBCOMMAND"

	Scenario: Can execute config with -h and get usage info
		When I run `dab config -h`

		Then it should pass with "SUBCOMMAND"

	Scenario Outline: Can set and retrieve config values
		The user should be able to get and set arbitrary config key value pairs.

		When I successfully run `dab config set <KEY> <VALUE>`

		Then it should pass with exactly:
		"""
		setting config key <KEY> to <VALUE>
		"""

		When I run `dab config get <KEY>`

		Then it should pass with exactly:
		"""
		<VALUE>
		"""
		And the file "/tmp/dab/config/<KEY>" should contain exactly:
		"""
		<VALUE>
		"""

		Examples:
			| KEY     | VALUE    |
			| foo     | bar      |
			| foo     | barry    |
			| bar.foo | 42       |
			| bar.foo | 42 barry |

	Scenario Outline: Setting config values is an idempotent operation
		The user should be able to set a config multiple times with the same
		value and it only apply once.

		Given I successfully run `dab config set <KEY> <VALUE>`
		And the output should contain exactly:
		"""
		setting config key <KEY> to <VALUE>
		"""

		When I successfully run `dab config set <KEY> <VALUE>`
		Then the output should not contain anything

		When I run `dab config get <KEY>`
		Then it should pass with exactly:
		"""
		<VALUE>
		"""

		Examples:
			| KEY     | VALUE    |
			| soo     | lan      |
			| soo     | larry    |
			| dar.foo | 42       |
			| dar.foo | 42 larry |

	Scenario Outline: Can add to a config value making a list
		The user should be able to set a config value and then add to it to
		make a list, note setting will replace the list with the single new
		element.

		Given I successfully run `dab config set <KEY> <FIRST>`

		When I run `dab config add <KEY> <SECOND>`

		Then it should pass with exactly:
		"""
		added <SECOND> to config key <KEY> which now contains 2 value(s)
		"""
		And the file "/tmp/dab/config/<KEY>" should contain exactly:
		"""
		<FIRST>
		<SECOND>
		"""
		And I run `dab config get <KEY>`
		And it should pass with exactly:
		"""
		<FIRST>
		<SECOND>
		"""

		Examples:
			| KEY        | FIRST  | SECOND |
			| thing1     | foo    | bar    |
			| thing2     | barry  | allen  |
			| thing3/foo | 42     | lolwut |
			| thing4/goo | 42 foo | lolwut |
			| thing5/poo | 42 foo | lol 42 |

	Scenario: Can add to a config key that does not exist to create a new list
		The user should be able to add without having already done a set.

		When I run `dab config add plumbus schleem`

		Then it should pass with exactly:
		"""
		added schleem to config key plumbus which now contains 1 value(s)
		"""
		And the file "/tmp/dab/config/plumbus" should contain exactly:
		"""
		schleem
		"""
		And I run `dab config get plumbus`
		And it should pass with exactly:
		"""
		schleem
		"""

	Scenario: Adding config values to a list is an idempotent operation

		Given I successfully run `dab config add shleembop bloof`
		And the output should contain exactly:
		"""
		added bloof to config key shleembop which now contains 1 value(s)
		"""

		When I successfully run `dab config add shleembop bloof`

		Then the output should not contain anything

	Scenario: Adding config values to non list is an idempotent operation

		Given I successfully run `dab config set pewpew boom`
		And the output should contain exactly:
		"""
		setting config key pewpew to boom
		"""

		When I successfully run `dab config add pewpew boom`

		Then the output should not contain anything

	Scenario Outline: Can erase config items with an empty set
		By not giving a value to assign to a key when running the `config set`
		subcommand that key will be deleted.

		Given I successfully run `dab config set <KEY> toErase`
		And the file "/tmp/dab/config/<KEY>" should exist

		When I successfully run `dab config set <KEY>`

		Then the file "/tmp/dab/config/<KEY>" should not exist anymore

		Examples:
			| KEY     |
			| foo     |
			| bar/foo |
