# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab config
	The config subcommand manages the dab configuration key value store. Config
	keys are any word or sequence of words (for namespacing) delimited by a
	forward slash, eg. `foo/bar` would store the url for the dab repository.

	Scenario Outline: Can set and retrieve config values
		Config values can be altered and retrieved with set and get respectively.

		Given I successfully run `dab config set <KEY> <VALUE>`
		And it should pass with:
		"""
		setting config key <KEY> to <VALUE>
		"""

		Then I run `dab config get <KEY>`
		And it should pass with:
		"""
		<VALUE>
		"""
		And the file "~/.config/dab/<KEY>" should contain exactly:
		"""
		<VALUE>
		"""

		Examples:
			| KEY     | VALUE    |
			| foo     | bar      |
			| foo     | barry    |
			| bar.foo | 42       |
			| bar.foo | 42 barry |

	Scenario: Can display a tree of config keys
		Given I successfully run `dab config set flume/log foo`

		When I run `dab config keys`

		Then it should pass with "├── flume"

	Scenario: Can display a tree of config keys at a specific namespace
		Given I successfully run `dab config set boogie/nights 2`

		When I run `dab config keys boogie`

		Then it should pass with "└── nights"

	Scenario Outline: Can add to a config value making a list
		Config values can also be a list of values, represented by lines in a
		file. Note setting will replace the list with the single new element.

		Given I successfully run `dab config set <KEY> <FIRST>`

		When I run `dab config add <KEY> <SECOND>`

		Then it should pass with:
		"""
		added <SECOND> to config key <KEY> which now contains 2 value(s)
		"""
		And the file "~/.config/dab/<KEY>" should contain exactly:
		"""
		<FIRST>
		<SECOND>
		"""
		And I run `dab config get <KEY>`
		And it should pass with:
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
		You can add values to a config key, creating it when it does not exist.
		Given I successfully run `dab config set plumbus`

		When I run `dab config add plumbus schleem`

		Then it should pass with:
		"""
		added schleem to config key plumbus which now contains 1 value(s)
		"""
		And the file "~/.config/dab/plumbus" should contain exactly:
		"""
		schleem
		"""
		And I run `dab config get plumbus`
		And it should pass with:
		"""
		schleem
		"""

	Scenario: Adding config values to a list is an idempotent operation
		If you add a config value to a list that is already has that value is
		will do nothing.

		Given I successfully run `dab config set shleembop bloof`

		When I successfully run `dab config add shleembop bloof`

		Then the output should not contain:
		"""
		added bloof to config key shleembop which now contains 1 value(s)
		"""

	Scenario Outline: Can erase config items with an empty set
		By not giving a value to assign to a key that key will be deleted.

		Given I successfully run `dab config set <KEY> toErase`
		And the file "~/.config/dab/<KEY>" should exist

		When I successfully run `dab config set <KEY>`

		Then the file "~/.config/dab/<KEY>" should not exist anymore

		Examples:
			| KEY     |
			| foo     |
			| bar/foo |

	Scenario: You cannot make a key a namespace
		Under everything keys are files and so have the same properties.

		Given I successfully run `dab config set jaffa kree`

		When I run `dab config set jaffa/tealc kree`

		Then it should fail with "File exists"

	Scenario: You cannot make a namespace a key
		Under everything namespaces are directories and so have the same properties.

		Given I successfully run `dab config set asguard/thor "The O'Neill"`

		When I run `dab config set asguard lost`

		Then it should fail with "Is a directory"

	Scenario: Can set environment variables with config
		Given I successfully run `dab config set environment/SOME_ENV toshi`

		When I run `dab shell echo \$SOME_ENV`

		Then it should pass with "toshi"
