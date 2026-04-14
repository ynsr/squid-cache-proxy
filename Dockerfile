FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SQUID_USER=proxy
ENV SQUID_GROUP=proxy
ENV SSL_DB_DIR=/var/lib/squid/ssl_db
ENV SQUID_CACHE_DIR=/var/spool/squid
ENV SQUID_LOG_DIR=/var/log/squid
ENV SQUID_SSL_DIR=/etc/squid/ssl

cat >  /etc/apt/sources.list << 'EOF'
deb http://mirror.arvancloud.ir/ubuntu jammy universe
EOF

# Install Squid with SSL support
RUN apt-get update && apt-get install -y \
    squid-openssl \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p ${SQUID_CACHE_DIR} \
             ${SQUID_LOG_DIR} \
             ${SQUID_SSL_DIR} \
             ${SSL_DB_DIR}

# Set proper permissions
RUN chown -R ${SQUID_USER}:${SQUID_GROUP} \
        ${SQUID_CACHE_DIR} \
        ${SQUID_LOG_DIR} \
        ${SSL_DB_DIR} \
        ${SQUID_SSL_DIR}

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Expose Squid ports
EXPOSE 3128 3129 3130

# Use the custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["squid", "-N", "-f", "/etc/squid/squid.conf"]
