#!/bin/bash
set -e

ACCESS_MODE="${ACCESS_MODE:-restricted}"
PORT="${PORT:-8000}"

# No MCP_AUTH_KEY: unchanged behaviour. postgres-mcp listens on $PORT directly
# with no authentication of its own.
if [ -z "${MCP_AUTH_KEY:-}" ]; then
  exec postgres-mcp \
    --transport=streamable-http \
    --streamable-http-host=0.0.0.0 \
    --streamable-http-port="${PORT}" \
    --access-mode="${ACCESS_MODE}"
fi

# MCP_AUTH_KEY set: postgres-mcp moves to loopback and an in-container nginx
# on $PORT requires "Authorization: Bearer <MCP_AUTH_KEY>" (except /health).
MCP_INTERNAL_PORT="${MCP_INTERNAL_PORT:-8000}"
NGINX_DIR=/tmp/nginx

# The key is written into the nginx config, so restrict it to characters that
# are safe there (same set the gateway accepts for API_KEYS).
case "$MCP_AUTH_KEY" in
  *[!A-Za-z0-9._~+/=-]*)
    echo "mcp: MCP_AUTH_KEY contains an invalid character; allowed: A-Z a-z 0-9 . _ ~ + / = -" >&2
    exit 1
    ;;
esac

if [ "$PORT" = "$MCP_INTERNAL_PORT" ]; then
  echo "mcp: PORT ($PORT) and MCP_INTERNAL_PORT ($MCP_INTERNAL_PORT) must differ when MCP_AUTH_KEY is set" >&2
  exit 1
fi

# Listen on IPv6 too when the container has it (Railway private networking
# can be IPv6); skip it where IPv6 is disabled, or nginx refuses to start.
LISTEN_V6=""
if [ -s /proc/net/if_inet6 ]; then
  LISTEN_V6="listen [::]:${PORT};"
fi

mkdir -p "$NGINX_DIR"
sed \
  -e "s|@@NGINX_DIR@@|${NGINX_DIR}|g" \
  -e "s|@@PORT@@|${PORT}|g" \
  -e "s|@@LISTEN_V6@@|${LISTEN_V6}|g" \
  -e "s|@@UPSTREAM_PORT@@|${MCP_INTERNAL_PORT}|g" \
  -e "s|@@MCP_AUTH_KEY@@|${MCP_AUTH_KEY}|g" \
  /etc/mcp-nginx/nginx.conf.template > "$NGINX_DIR/nginx.conf"

nginx -e stderr -p "$NGINX_DIR" -c "$NGINX_DIR/nginx.conf" -t -q

postgres-mcp \
  --transport=streamable-http \
  --streamable-http-host=127.0.0.1 \
  --streamable-http-port="${MCP_INTERNAL_PORT}" \
  --access-mode="${ACCESS_MODE}" &
MCP_PID=$!

nginx -e stderr -p "$NGINX_DIR" -c "$NGINX_DIR/nginx.conf" -g 'daemon off;' &
NGINX_PID=$!

stop() {
  kill -TERM "$MCP_PID" "$NGINX_PID" 2>/dev/null || true
  wait "$MCP_PID" "$NGINX_PID" 2>/dev/null || true
  exit 0
}
trap stop TERM INT

# If either process exits, stop the other and exit non-zero so Railway
# restarts the container instead of leaving a half-alive service.
set +e
wait -n "$MCP_PID" "$NGINX_PID"
STATUS=$?
echo "mcp: a supervised process exited (status $STATUS); stopping the container" >&2
kill -TERM "$MCP_PID" "$NGINX_PID" 2>/dev/null
wait "$MCP_PID" "$NGINX_PID" 2>/dev/null
exit 1
