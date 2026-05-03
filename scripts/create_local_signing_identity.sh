#!/usr/bin/env bash
set -euo pipefail

IDENTITY_NAME="${1:-MouseCopyPaste Local Signing}"
P12_PASSWORD="${MOUSECOPYPASTE_P12_PASSWORD:-mousecopypaste-local-signing}"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

if security find-identity -p codesigning -v | grep -q "\"$IDENTITY_NAME\""; then
  echo "$IDENTITY_NAME already exists"
  exit 0
fi

if security find-certificate -c "$IDENTITY_NAME" "$HOME/Library/Keychains/login.keychain-db" >/dev/null 2>&1; then
  security delete-certificate -c "$IDENTITY_NAME" "$HOME/Library/Keychains/login.keychain-db" >/dev/null 2>&1 || true
fi

cat > "$WORK_DIR/cert.conf" <<EOF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no

[dn]
CN = $IDENTITY_NAME

[ext]
basicConstraints = critical,CA:true
keyUsage = critical,digitalSignature,keyCertSign
extendedKeyUsage = critical,codeSigning
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF

openssl req \
  -x509 \
  -newkey rsa:2048 \
  -keyout "$WORK_DIR/key.pem" \
  -out "$WORK_DIR/cert.pem" \
  -days 3650 \
  -nodes \
  -config "$WORK_DIR/cert.conf"

openssl pkcs12 \
  -export \
  -legacy \
  -out "$WORK_DIR/identity.p12" \
  -inkey "$WORK_DIR/key.pem" \
  -in "$WORK_DIR/cert.pem" \
  -passout "pass:$P12_PASSWORD"

security import "$WORK_DIR/identity.p12" \
  -k "$HOME/Library/Keychains/login.keychain-db" \
  -P "$P12_PASSWORD" \
  -T /usr/bin/codesign

security add-trusted-cert \
  -d \
  -r trustRoot \
  -p codeSign \
  -k "$HOME/Library/Keychains/login.keychain-db" \
  "$WORK_DIR/cert.pem"

echo "Created code signing identity: $IDENTITY_NAME"
