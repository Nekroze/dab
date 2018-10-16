# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab pki
	Provides a easy to use x509 Public Key Infrastructure.

	Background:
		Many of the pki run commands require a tty, this is handled in these
		scenarios by prefixing commands with `script -qec` but real users will
		not need to do this.

		Given the aruba exit timeout is 300 seconds
		And I successfully run `dab pki destroy`

	@announce-output
	Scenario: Can issue x509 certificate
		Given I successfully run `script -qec 'dab pki ready'`

		When I successfully run `script -qec 'dab pki issue web.test.lan'`

		Then I run `dab config get pki/web.test.lan/certificate`
		And it should pass with "BEGIN CERTIFICATE"
		And I successfully run `openssl x509 -text -noout -in /root/.config/dab/pki/web.test.lan/certificate`
		And the output should contain "CN = web.test.lan"
		And the output should contain "DNS:*.web.test.lan"
		And the output should contain "DNS:web.test.lan"
		And I successfully run `openssl verify -CAfile /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/web.test.lan/certificate`

	@announce-output
	Scenario: PKI persists across reboots
		Given I successfully run `script -qec 'dab pki ready'`
		And I copy the file "~/.config/dab/pki/ca/certificate" to "~/.config/dab/pki/ca/certificate.original"
		And I successfully run `script -qec 'dab pki issue git.test.lan'`

		When I successfully run `dab services stop`
		And I successfully run `script -qec 'dab pki ready'`
		And I successfully run `script -qec 'dab pki issue git.test.lan'`

		Then I successfully run `openssl verify -CAfile /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/git.test.lan/certificate`
		And I successfully run `diff /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/ca/certificate.original`
		And the output should not contain anything
