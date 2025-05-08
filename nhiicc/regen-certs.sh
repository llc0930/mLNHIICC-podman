#!/bin/sh

# Adapted from upstream ./Install script
org=nhi-localhost-ca
domain=localhost
# Upstream script generates 50 year leaf cert and 30 day CA cert.
# 10 years for both sound like a better choice.
days=3650

set -eu

out_dir=/usr/local/share/NHIICC/cert
mkdir -p "$out_dir"

tmp_dir="$(mktemp -d --tmpdir tmp.nhiicc-XXXXXX)"
trap 'rm -rf -- "$tmp_dir"' EXIT

cd "$tmp_dir"

openssl genpkey -algorithm RSA -out ca.key
openssl req -x509 -key ca.key -days $days -out ca.crt \
    -subj "/CN=$org/O=$org"

openssl genpkey -algorithm RSA -out "$domain".key
openssl req -new -key "$domain".key -out "$domain".csr \
    -subj "/CN=$domain/O=$org"

tmp="$(mktemp)"
cat > "$tmp" << END
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = DNS:$domain
END

openssl x509 -req -in "$domain".csr -days $days -out "$domain".crt \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
-extfile "$tmp"

install -Dm644 ca.crt /usr/local/share/ca-certificates/NHIRootCA.crt
install -Dm644 ca.crt "$out_dir/NHIRootCA.crt"
install -Dm644 localhost.crt "$out_dir/NHIServerCert.crt"
install -Dm600 localhost.key "$out_dir/NHIServerCert.key"

update-ca-certificates
