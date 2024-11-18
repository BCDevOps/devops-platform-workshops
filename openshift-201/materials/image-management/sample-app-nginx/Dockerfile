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

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Expose port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
