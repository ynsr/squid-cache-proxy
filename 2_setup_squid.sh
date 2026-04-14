#!/bin/bash
set -e

SQUID_DIR="/srv/appdata/squid"
SSL_DIR="$SQUID_DIR/ssl"
SSL_DB_DIR="$SQUID_DIR/ssl_db"
CONFIG_DIR="$SQUID_DIR/config"

echo "=== [1/4] Creating directories ==="
mkdir -p "$SQUID_DIR"/{config,cache,ssl,ssl_db,logs}

# ─── CA Certificate ───────────────────────────────────────────────
echo "=== [2/4] Generating CA Certificate ==="
openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 \
    -keyout "$SSL_DIR/squid-ca.key" \
    -out    "$SSL_DIR/squid-ca.crt" \
    -subj   "/CN=R6S-SquidCA/O=HomeProxy/C=US"

cat "$SSL_DIR/squid-ca.key" \
    "$SSL_DIR/squid-ca.crt" > "$SSL_DIR/squid-ca.pem"

chmod 600 "$SSL_DIR/squid-ca.key"
chmod 644 "$SSL_DIR/squid-ca.crt" "$SSL_DIR/squid-ca.pem"
echo "✅ CA certificate created"

# ─── SSL Certificate Database ─────────────────────────────────────
echo "=== [3/4] Initializing SSL Certificate Database ==="
docker run --rm \
    -v "$SSL_DB_DIR:/var/lib/squid/ssl_db" \
    squid-ssl-arm64 \
    bash -c "
        /usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db/ssl_db -M 16MB
        chown -R proxy:proxy /var/lib/squid/ssl_db
    "
echo "✅ SSL DB initialized"

# ─── Squid Config ─────────────────────────────────────────────────
echo "=== [4/4] Writing squid.conf ==="
cp ./config/*  "$CONFIG_DIR/"
echo "✅ squid.conf copied"

echo ""
echo "=== ✅ Setup complete! Run: docker compose -f /srv/appdata/squid/docker-compose.yml up -d ==="
echo "=== 📄 CA cert to copy to Windows: $SSL_DIR/squid-ca.crt ==="
