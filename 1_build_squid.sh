#!/bin/bash
set -e

echo "=== [1/3] Creating directories ==="
mkdir -p /mnt/squid/{build,config,cache,ssl,ssl_db,logs}

#echo "=== [2/3] Writing Dockerfile ==="
#cp ./Dockerfile /mnt/squid/build/Dockerfile

echo "=== [3/3] Building Docker image (this may take a few minutes) ==="
#docker build -t squid-arm64 /mnt/squid/build/
docker build -t squid-arm64 .

echo ""
echo "=== Verifying SSL support ==="
docker run --rm squid-arm64 squid -v | grep -i ssl \
    && echo "✅ SSL support confirmed!" \
    || echo "❌ SSL not found — check Dockerfile"
