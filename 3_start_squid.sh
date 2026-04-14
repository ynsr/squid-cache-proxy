#!/bin/bash

SQUID_DIR="/srv/appdata/squid"
ACTION=${1:-start}

case "$ACTION" in
  start)
    echo "=== Starting Squid ==="
    docker compose -f "$SQUID_DIR/docker-compose.yml" up -d
    sleep 3
    docker ps | grep squid
    echo ""
    netstat -tlnp | grep 3128
    echo "✅ Squid running on 192.168.88.110:3128"
    ;;
  stop)
    docker compose -f "$SQUID_DIR/docker-compose.yml" down
    echo "✅ Squid stopped"
    ;;
  restart)
    docker compose -f "$SQUID_DIR/docker-compose.yml" restart
    echo "✅ Squid restarted"
    ;;
  logs)
    docker exec squid-proxy tail -f /var/log/squid/access.log
    ;;
  stats)
    echo "=== Cache Statistics ==="
    docker exec squid-proxy squidclient -h localhost mgr:info \
        | grep -E "hits|misses|Mean|Storage|cached"
    echo ""
    echo "=== Last 100 requests HIT/MISS ==="
    docker exec squid-proxy tail -100 /var/log/squid/access.log \
        | awk '{print $4}' | sort | uniq -c | sort -rn
    ;;
  status)
    docker ps | grep squid
   ;;
  *)
    echo "Usage: $0 {start|stop|restart|logs|stats|status}"
    ;;
esac