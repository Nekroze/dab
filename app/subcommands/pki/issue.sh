#!/bin/sh
# Description: Issue/renew a wildcard tls certificate for the given domain name
# Usage: <FQDN>
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

# shellcheck disable=SC1091
. ./lib/output.sh
# shellcheck disable=SC1091
. ./lib/vault.sh
# shellcheck disable=SC1091
. ./lib/services.sh
# shellcheck disable=SC1091
. ./lib/compose.sh

[ -n "${1:-}" ] || fatality 'must provide a fqdn name'
fqdn="$1"
role="$(echo "$fqdn" | sed 's/\./-/g')"

await_service_healthy vault

vault write "pki_dab/roles/$role" \
	allowed_domains="$fqdn" \
	allow_bare_domains=true \
	allow_subdomains=true

pki_path="$DAB_CONF_PATH/pki/$fqdn"
mkdir -p "$pki_path"
vaultbot --vault_token="$(vault_token)" \
	--pki_mount=pki_dab \
	--pki_role_name="$role" \
	--pki_common_name="$fqdn" \
	--pki_alt_names="*.$fqdn" \
	--pki_ttl="${DAB_PKI_TTL:-168h}" \
	--pki_cert_path="$pki_path/certificate" \
	--pki_privkey_path="$pki_path/key" \
	-y
toolpose run --entrypoint /bin/sh vaultbot -c "chown $DAB_UID:$DAB_GID $pki_path/*"
toolpose run --entrypoint /bin/sh vaultbot -c "chmod 644 $pki_path/*"

conf_path="\$DAB_CONF_PATH/pki/$fqdn"
inform "$fqdn pem formatted certificate can be found at $conf_path/certificate"
inform "$fqdn pem formatted private key can be found at $conf_path/key"
