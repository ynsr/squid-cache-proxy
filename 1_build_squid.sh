#!/bin/bash
set -e

echo "=== [1/3] Creating directories ==="
mkdir -p /mnt/squid/{build,config,cache,ssl,ssl_db,logs}

echo "=== [2/3] Writing Dockerfile ==="
cat > /mnt/squid/build/Dockerfile << 'EOF'
FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    squid-openssl \
    openssl \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/spool/squid \
             /var/log/squid \
             /etc/squid/ssl \
             /var/lib/squid/ssl_db \
    && chown -R proxy:proxy \
             /var/spool/squid \
             /var/log/squid \
             /var/lib/squid/ssl_db

EXPOSE 3128

CMD ["squid", "-NYCd", "1"]
EOF

echo "=== [3/3] Building Docker image (this may take a few minutes) ==="
docker build -t squid-ssl-arm64 /mnt/squid/build/

echo ""
echo "=== Verifying SSL support ==="
docker run --rm squid-ssl-arm64 squid -v | grep -i ssl \
    && echo "✅ SSL support confirmed!" \
    || echo "❌ SSL not found — check Dockerfile"