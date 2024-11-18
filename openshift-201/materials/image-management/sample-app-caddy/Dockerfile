FROM caddy:alpine

# Install envsubst tool (gettext package)
RUN apk add --no-cache gettext

ADD Caddyfile /opt/app-root/etc/Caddyfile

RUN chown -R 1001:0 /opt/app-root/src
RUN chmod -R 775 /opt/app-root/*

USER 1001

EXPOSE 2015

# Copy the template file for the index
COPY index.html.template /opt/app-root/src/index.html.template

# Run envsubst to replace environment variables in the template, then start Caddy
CMD ["sh", "-c", "envsubst < /opt/app-root/src/index.html.template > /opt/app-root/src/index.html && caddy run --config /opt/app-root/etc/Caddyfile"]

