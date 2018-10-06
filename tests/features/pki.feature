# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab pki
	Provides a easy to use x509 Public Key Infrastructure.

	Background:
		Many of the pki run commands require a tty, this is handled in these
		scenarios by prefixing commands with `script -qec` but real users will
		not need to do this.

		Given the aruba exit timeout is 60 seconds
		And I successfully run `dab pki destroy`

	Scenario: Can issue x509 certificate
		Given I run `script -qec 'dab pki ready'`

		When I successfully run `script -qec 'dab pki issue web.test.lan'`

		Then I run `dab config get pki/web.test.lan/certificate`
		And it should pass with "BEGIN CERTIFICATE"
		And I successfully run `openssl x509 -text -noout -in /tmp/dab/config/pki/web.test.lan/certificate`
		And the output should contain "CN = web.test.lan"
		And the output should contain "DNS:*.web.test.lan"
		And the output should contain "DNS:web.test.lan"
		And I successfully run `openssl verify -CAfile /tmp/dab/config/pki/ca/certificate /tmp/dab/config/pki/web.test.lan/certificate`

	Scenario: PKI persists across reboots
		Given I successfully run `script -qec 'dab pki ready'`
		And I copy the file "/tmp/dab/config/pki/ca/certificate" to "/tmp/dab/config/pki/ca/certificate.original"
		And I successfully run `script -qec 'dab pki issue git.test.lan'`

		When I successfully run `dab services stop`
		And I successfully run `script -qec 'dab pki ready'`
		And I successfully run `script -qec 'dab pki issue git.test.lan'`
		And I run `ls -al /tmp/dab/config/pki/ca/certificate`
		And I run `ls -al /tmp/dab/config/pki/git.test.lan/certificate`

		Then I successfully run `openssl verify -CAfile /tmp/dab/config/pki/ca/certificate /tmp/dab/config/pki/git.test.lan/certificate`
		And I successfully run `diff /tmp/dab/config/pki/ca/certificate /tmp/dab/config/pki/ca/certificate.original`
		And the output should not contain anything
