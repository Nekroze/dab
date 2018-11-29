#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1090
. "$DAB/lib/docker.sh"
# shellcheck disable=SC1090
. "$DAB/lib/config.sh"

vault() {
	dpose apps exec -T vault vault "$@"
}

vault_init() {
	vault operator init -key-shares=1 -key-threshold=1 -format=json
}

vault_token_memoized=
vault_token() {
	if [ -n "${vault_token_memoized:-}" ]; then
		echo "$vault_token_memoized"
		return 0
	fi
	vault_token_memoized="$(
		config_get pki/vault/init | jq -r .root_token
	)"
	echo "$vault_token_memoized"
}

vault_key_memoized=
vault_key() {
	if [ -n "${vault_key_memoized:-}" ]; then
		echo "$vault_key_memoized"
		return 0
	fi
	vault_key_memoized="$(
		config_get pki/vault/init | jq -r .unseal_keys_b64[0]
	)"
	echo "$vault_key_memoized"
}

vault_status_memoized=
vault_status() {
	if [ -n "${vault_status_memoized:-}" ]; then
		echo "$vault_status_memoized"
		return 0
	fi
	vault_status_memoized="$(vault status --format=json)"
	echo "$vault_status_memoized"
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
	dpose apps run --rm vaultbot "$@"
}
