#!/bin/sh
# install-ca.sh
# Install a self-signed Squid CA certificate on OpenWrt/FriendlyWRT

set -e

CERT_NAME="squid-ca.crt"
SOURCE_CERT="./${CERT_NAME}"
DEST_CERT="/usr/local/share/ca-certificates/${CERT_NAME}"
CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

echo "=== Registering Squid CA Certificate ==="

# 1. Verify certificate exists
if [ ! -f "$SOURCE_CERT" ]; then
    echo "Error: Certificate not found at $SOURCE_CERT"
    exit 1
fi

# 2. Ensure destination directory exists
mkdir -p /usr/local/share/ca-certificates

# 3. Copy the certificate
echo "Copying certificate to $DEST_CERT..."
cp "$SOURCE_CERT" "$DEST_CERT"

# 4. Set appropriate permissions
chmod 644 "$DEST_CERT"

# 5. Append certificate to system CA bundle if not already present
if ! grep -q "$(openssl x509 -noout -subject -in "$DEST_CERT")" "$CA_BUNDLE" 2>/dev/null; then
    echo "Updating system CA bundle..."
    cat "$DEST_CERT" >> "$CA_BUNDLE"
else
    echo "Certificate already present in CA bundle."
fi

# 6. Rehash certificates (if c_rehash is available)
if command -v c_rehash >/dev/null 2>&1; then
    echo "Rehashing certificates..."
    c_rehash /etc/ssl/certs >/dev/null 2>&1
elif command -v openssl >/dev/null 2>&1; then
    echo "Rehashing certificates using OpenSSL..."
    openssl rehash /etc/ssl/certs >/dev/null 2>&1 || true
fi

echo "=== Squid CA certificate successfully installed! ==="
echo "You may need to restart services like squid, wget, or curl."
