FROM  squid-ssl-arm64

ENV DEBIAN_FRONTEND=noninteractive

# Create required directories & Set proper permissions
RUN mkdir -p /var/spool/squid \
             /var/log/squid \
             /etc/squid/ssl \
             /var/lib/squid/ssl_db \
    && chown -R proxy:proxy \
             /var/spool/squid \
             /var/log/squid \
             /var/lib/squid/ssl_db

# Expose Squid ports
EXPOSE 3128 3129 3130

# Default command
CMD ["squid", "-NYCd", "1"]
