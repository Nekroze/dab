#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/docker.sh"
# shellcheck disable=SC1090
. "$DAB/lib/config.sh"

vault() {
	dpose vault exec -T vault vault "$@"
}

vault_init() {
	vault operator init -key-shares=1 -key-threshold=1 -format=json
}

vault_token() {
	config_get pki/vault/init | jq -r .root_token
}

vault_key() {
	config_get pki/vault/init | jq -r .unseal_keys_b64[0]
}

vault_status() {
	vault status --format=json
}

vault_initialized() {
	sealed="$(vault_status | jq -M .initialized)"
	[ "$sealed" = 'true' ]
	return $?
}

vault_sealed() {
	sealed="$(vault_status | jq -M .sealed)"
	[ "$sealed" = 'true' ]
	return $?
}

vault_pki_enabled() {
	vault secrets list | awk '{ print $1; }' | silently grep pki_dab/
}

vaultbot() {
	dpose vaultbot run --rm vaultbot "$@"
}
