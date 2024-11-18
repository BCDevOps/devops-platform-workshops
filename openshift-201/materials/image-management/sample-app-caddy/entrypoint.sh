#!/bin/sh

# Use envsubst to substitute environment variables in the template file
envsubst < /app/index.html.template > /app/index.html

# Start the Caddy server, pointing to the output directory
exec /usr/bin/caddy run --config /etc/caddy/Caddyfile
