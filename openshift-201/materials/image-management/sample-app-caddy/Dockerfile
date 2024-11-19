FROM caddy:alpine

# Install envsubst for runtime variable substitution
RUN apk add --no-cache gettext

# Ensure directories have proper permissions for arbitrary users
RUN mkdir -p /app && \
    chown -R 0:0 /app && \
    chmod -R g=u /app

# Make sure caddy binary is executable by everyone
RUN chmod +x /usr/bin/caddy


# Set the working directory
WORKDIR /app

# Copy static file templates and scripts
COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html.template /app/index.html.template
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# CMD ["/app/entrypoint.sh"]

CMD ["caddy run --config /etc/caddy/Caddyfile"]
