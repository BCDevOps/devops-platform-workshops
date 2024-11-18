# FROM nginx:alpine
FROM openresty/openresty:alpine

# Install envsubst (part of gettext)
RUN apk add --no-cache gettext

# Copy entrypoint script and HTML template
# COPY entrypoint.sh /entrypoint.sh

# Create a custom directory for serving files
RUN mkdir -p /app/html && chown -R 1001:0 /app/html && chmod -R g+w /app/html

# # Copy template to the custom directory
# COPY index.html.template /app/html/index.html.template
# COPY default.conf /app/html/default.conf



COPY nginx.conf /app/html/nginx.conf

# Make the entrypoint script executable
# RUN chmod +x /entrypoint.sh

# Set the default user to a non-root user (OpenShift default user)
USER 1001

# Expose port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;", "-c", "/app/html/nginx.conf"]
