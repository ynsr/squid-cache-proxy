#!/bin/bash
set -e

SQUID_USER=${SQUID_USER:-proxy}
SQUID_GROUP=${SQUID_GROUP:-proxy}
SSL_DB_DIR=${SSL_DB_DIR:-/var/lib/squid/ssl_db}
SQUID_CACHE_DIR=${SQUID_CACHE_DIR:-/var/spool/squid}
SQUID_SSL_DIR=${SQUID_SSL_DIR:-/etc/squid/ssl}
CERTGEN=""

echo "🔍 Locating security_file_certgen..."

# Detect the correct path for security_file_certgen
if [ -x /usr/lib/squid/security_file_certgen ]; then
    CERTGEN="/usr/lib/squid/security_file_certgen"
elif [ -x /usr/libexec/squid/security_file_certgen ]; then
    CERTGEN="/usr/libexec/squid/security_file_certgen"
else
    echo "❌ security_file_certgen not found!"
    exit 1
fi

echo "✅ Using cert generator: $CERTGEN"

# Ensure directories exist
mkdir -p "$SSL_DB_DIR" "$SQUID_CACHE_DIR" "$SQUID_SSL_DIR"

# Set permissions
chown -R ${SQUID_USER}:${SQUID_GROUP} \
    "$SSL_DB_DIR" "$SQUID_CACHE_DIR" "$SQUID_SSL_DIR" /var/log/squid

# Initialize SSL certificate database if not already present
if [ ! -f "$SSL_DB_DIR/index.txt" ]; then
    echo "🔐 Initializing Squid SSL certificate database..."
    sudo -u ${SQUID_USER} $CERTGEN -c -s "$SSL_DB_DIR" -M 16MB
else
    echo "ℹ️ SSL certificate database already initialized."
fi

# Initialize cache directories (idempotent)
echo "📦 Initializing Squid cache directories..."
squid -z || true

# Generate a self-signed CA certificate if not provided
if [ ! -f "$SQUID_SSL_DIR/squid-ca.pem" ]; then
    echo "🔑 Generating self-signed Squid CA certificate..."
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -keyout "$SQUID_SSL_DIR/squid-ca.key" \
        -out "$SQUID_SSL_DIR/squid-ca.crt" \
        -subj "/C=TR/ST=Istanbul/L=Istanbul/O=Squid Proxy/CN=Squid-CA"

    cat "$SQUID_SSL_DIR/squid-ca.key" \
        "$SQUID_SSL_DIR/squid-ca.crt" > "$SQUID_SSL_DIR/squid-ca.pem"

    chown ${SQUID_USER}:${SQUID_GROUP} "$SQUID_SSL_DIR"/squid-ca.*
    chmod 600 "$SQUID_SSL_DIR/squid-ca.key"
    chmod 644 "$SQUID_SSL_DIR/squid-ca.crt" "$SQUID_SSL_DIR/squid-ca.pem"

    echo "✅ Self-signed CA certificate generated."
else
    echo "ℹ️ Existing CA certificate found."
fi

echo "🚀 Starting Squid..."
exec "$@"
