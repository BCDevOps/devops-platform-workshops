FROM caddy:alpine

# Install envsubst for runtime variable substitution
RUN apk add --no-cache gettext

# Create and set up a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy static file templates and scripts
COPY index.html.template /app/index.html.template
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create the directory where Caddy will serve files
RUN mkdir -p /srv && chown -R appuser:appgroup /srv

# Ensure the container uses the non-root user
USER appuser

# Default command
CMD ["/app/entrypoint.sh"]
