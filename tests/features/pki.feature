# vim: ts=4 sw=4 sts=4 noet
Feature: Subcommand: dab pki
	Provides a easy to use x509 Public Key Infrastructure.

	Background:
		Given the aruba exit timeout is 600 seconds
		And I successfully run `dab pki destroy`

	Scenario: Can issue x509 certificate
		Given I successfully run `dab pki ready`

		When I successfully run `dab pki issue web.test.lan`

		Then I run `dab config get pki/web.test.lan/certificate`
		And it should pass with "BEGIN CERTIFICATE"
		And I successfully run `openssl x509 -text -noout -in /root/.config/dab/pki/web.test.lan/certificate`
		And the output should match /CN\s*=\s*web.test.lan$/
		And the output should contain "DNS:*.web.test.lan"
		And the output should contain "DNS:web.test.lan"
		And I successfully run `openssl verify -CAfile /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/web.test.lan/certificate`

	Scenario: PKI persists across reboots
		Given I successfully run `dab pki ready`
		And I copy the file "~/.config/dab/pki/ca/certificate" to "~/.config/dab/pki/ca/certificate.original"
		And I successfully run `dab pki issue git.test.lan`

		When I successfully run `dab services stop`
		And I successfully run `dab pki ready`
		And I successfully run `dab pki issue git.test.lan`

		Then I successfully run `openssl verify -CAfile /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/git.test.lan/certificate`
		And I successfully run `diff /root/.config/dab/pki/ca/certificate /root/.config/dab/pki/ca/certificate.original`

	Scenario: PKI Can be used in repo entrypoints
		Given I successfully run `dab repo add pkiconsumer https://github.com/Nekroze/dotfiles.git`
		And I successfully run `dab repo entrypoint create pkiconsumer certs`
		And I successfully run `dab config add repo/pkiconsumer/entrypoint/certs dab pki ready`
		And I successfully run `dab config add repo/pkiconsumer/entrypoint/certs dab pki issue consumer.test.lan`

		When I successfully run `dab repo entrypoint run pkiconsumer certs`

		Then I run `dab config get pki/consumer.test.lan/certificate`
		And it should pass with "BEGIN CERTIFICATE"
