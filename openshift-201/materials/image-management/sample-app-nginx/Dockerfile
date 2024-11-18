FROM nginx:alpine

# Install envsubst (part of gettext)
RUN apk add --no-cache gettext

# Copy Nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script and HTML template
COPY entrypoint.sh /entrypoint.sh
COPY index.html.template /usr/share/nginx/html/index.html.template

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Change permissions of the HTML directory to be writable
RUN chown -R 1001:0 /usr/share/nginx/html && chmod -R g+w /usr/share/nginx/html

# Set the default user to a non-root user (OpenShift default user)
USER 1001

# Expose port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
