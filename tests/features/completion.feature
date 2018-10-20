Feature: Shell completion for tab suggestions of commands and parameters

	Scenario: Dab completion binary is always installed when using dab

		Given I successfully run `dab help`

		Then the file "/root/.dab-completion" should exist

	Scenario: Can install dab completion bash

		Given a file named "/root/.bashrc" with ""

		When I successfully run `bash -c "/root/.dab-completion -install -y && source /root/.bashrc"`

		Then the file "/root/.bashrc" should contain:
		"""
		complete -C /root/.dab-completion dab
		"""

	Scenario Outline: Can get suggestions from the completion binary
		This test simulates bash using the completion binary to get suggestions for display.

		Given I successfully run `dab shell true`
		And an executable named "/usr/bin/get-completion" with:
		"""
		#!/usr/bin/env bash
		COMP_LINE=$*
		COMP_POINT=${#COMP_LINE}
		eval set -- "$@"
		COMP_WORDS=("$@")
		[ ${COMP_LINE[@]: -1} = ' ' ] && COMP_WORD+=('')
		COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
		~/.dab-completion
		printf '%s\n' "${COMPREPLY[@]}"
		"""

		When I run `get-completion '<INPUT>'`

		Then the output should contain "<EXPECTED_SUGGSTION>"

		Examples:
			| INPUT                 | EXPECTED_SUGGSTION |
			| dab c                 | changelog          |
			| dab c                 | config             |
			| dab config ad         | add                |
			| dab config g          | get                |
			| dab config k          | keys               |
			| dab config se         | set                |
			| dab gr                | group              |
			| dab group r           | repos              |
			| dab group s           | services           |
			| dab group s           | start              |
			| dab group too         | tools              |
			| dab group up          | update             |
			| dab he                | help               |
			| dab net               | network            |
			| dab network d         | destroy            |
			| dab network s         | shell              |
			| dab pki iss           | issue              |
			| dab pki re            | ready              |
			| dab p                 | pki                |
			| dab p                 | pki                |
			| dab repo a            | add                |
			| dab repo cl           | clone              |
			| dab repo entry        | entrypoint         |
			| dab repo entrypoint c | create             |
			| dab repo entrypoint s | start              |
			| dab repo entrypoint s | stop               |
			| dab repo f            | fetch              |
			| dab repo req          | require            |
			| dab services add      | address            |
			| dab services de       | destroy            |
			| dab services e        | exec               |
			| dab services l        | list               |
			| dab services l        | logs               |
			| dab services r        | restart            |
			| dab services r        | run                |
			| dab services s        | start              |
			| dab services s        | status             |
			| dab services s        | stop               |
			| dab services upd      | update             |
			| dab sh                | shell              |
			| dab s                 | services           |
			| dab s                 | shell              |
			| dab tools add         | address            |
			| dab tools de          | destroy            |
			| dab tools e           | exec               |
			| dab tools l           | list               |
			| dab tools l           | logs               |
			| dab tools r           | restart            |
			| dab tools r           | run                |
			| dab tools s           | start              |
			| dab tools s           | status             |
			| dab tools s           | stop               |
			| dab tools upd         | update             |
			| dab t                 | tools              |
			| dab u                 | update             |
