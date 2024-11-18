FROM caddy:alpine

# Install envsubst for runtime variable substitution
RUN apk add --no-cache gettext

# Set permissions for OpenShift's non-root user (UID 1001)
RUN mkdir -p /app && \
    chown -R 1001:0 /app && \
    chmod -R g=u /app

# Set the working directory
WORKDIR /app

# Copy static file templates and scripts
COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html.template /app/index.html.template
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# # Create the directory where Caddy will serve files
# RUN mkdir -p /srv && chown -R appuser:appgroup /srv

# Ensure the container uses the non-root user
USER 1001

# Default command
CMD ["/app/entrypoint.sh"]
